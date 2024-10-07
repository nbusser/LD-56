extends TextureRect
class_name Painting

@onready var canvas: CanvasItem = Node2D.new()
@onready var map = $".."
@onready var line: Line2D = Line2D.new()
@onready var paintingRect = Rect2(global_position, size)
@onready var surface_area = $PaintingArea/CollisionShape2D
@onready var rectCheck = Rect2(Vector2.ZERO,size)

@onready var BORNE_INF = 0.5
@onready var DARK_COEF = 1.01

var image: Image
var basicTexture
var basicColorImage : Image

var canvas_list : Array[CanvasItem] = []
var viewports : Array[SubViewport] = []
var textures : Array[ViewportTexture] = []

enum RENDERING_ITEM {
 ALL_HISTORY,
 TMP_LINES,
 NEW_LINES
}

@onready var shaderMaterial = $"subviewports/ShaderSubViewport/ColorRect".material

# @onready var shaderMaterial = $"subviewports/ShaderSubViewport/TextureRect".material

func _ready():
	#reset(self.position, self.size);
	viewports.append($subviewports/ShaderSubViewport)
	textures.append(viewports[0].get_texture())
	# canvas_list.append(viewports[0].get_canvas_item())
	canvas_list.append(null)

	# ($"../DebugPainting" as TextureRect).texture = textures[RENDERING_ITEM.ALL_HISTORY]


func reset(painting_position: Vector2, painting_size: Vector2i):
	self.position = painting_position

	canvas_list = [canvas_list[0]]
	viewports = [viewports[0]]
	textures = [textures[0]]

	viewports[0].size = painting_size
	for i in range(1, 3):
		var canvas = Node2D.new()
		var vp: SubViewport = SubViewport.new()
		vp.size = painting_size
		RenderingServer.viewport_set_clear_mode(vp.get_viewport_rid(), RenderingServer.VIEWPORT_CLEAR_ALWAYS)
		RenderingServer.viewport_set_update_mode(vp.get_viewport_rid(), RenderingServer.VIEWPORT_UPDATE_ALWAYS)
		vp.transparent_bg = true
		var invisible_texture = vp.get_texture()
		vp.add_child(canvas)
		# $SubViewportContainer.add_child(vp)
		canvas_list.append(canvas)
		viewports.append(vp)
		textures.append(invisible_texture)
		$subviewports.add_child(vp)
	var base =  Image.create(painting_size.x, painting_size.y, false, Image.FORMAT_RGBA8)
	base.fill(Color(1,1,1,0))
	oldtex = ImageTexture.create_from_image(base)
	self.texture = textures[RENDERING_ITEM.ALL_HISTORY]

	# Also resize/shift the detection area
	var rect = RectangleShape2D.new()
	rect.size = painting_size
	self.surface_area.shape = rect
	self.surface_area.position = painting_size / 2.0

@onready var oldtex = ImageTexture.new()

@onready var flock = $"../Flock"
@onready var sounds = [
	$PaintSound,
	$PaintSound2,
	$PaintSound3
]
func _process(delta):
	var is_painting = false
	for boid in flock.boids:
		if boid.shouldPaint():
			var currentPos = boid.global_position
			var precedentPos = boid.previous_position
			var width = boid.color_quantity / 5.
			segments.append([precedentPos, currentPos, boid.color, width])
			boid.color_quantity -= 27 * delta
			if width >= 2.:
				is_painting = true
		boid.previous_position = boid.global_position
	if is_painting:
		if not $PaintSound.playing and not $PaintSound2.playing and not $PaintSound3.playing:
			var random_sound = randi() % sounds.size()
			sounds[random_sound].play_sound()

	draw_segments()
	segments.clear()
	# self.texture.update(self.image);
	#self.basicTexture.update(self.basicColorImage)
	rectCheck = Rect2(Vector2.ZERO,size)
	# await RenderingServer.frame_post_draw
	oldtex = ImageTexture.create_from_image(textures[RENDERING_ITEM.ALL_HISTORY].get_image())

func swap_rendering_items(a: RENDERING_ITEM, b: RENDERING_ITEM):
	var tmp = textures[a]
	textures[a] = textures[b]
	textures[b] = tmp

	tmp = viewports[a]
	viewports[a] = viewports[b]
	viewports[b] = tmp

	tmp = canvas_list[a]
	canvas_list[a] = canvas_list[b]
	canvas_list[b] = tmp

func merge():
	shaderMaterial.set_shader_parameter("history", oldtex)
	shaderMaterial.set_shader_parameter("tmp", textures[RENDERING_ITEM.TMP_LINES])
	shaderMaterial.set_shader_parameter("new", textures[RENDERING_ITEM.NEW_LINES])

func render_server_add_line(canvas_item: RID, from: Vector2, to: Vector2, color: Color, width: float = 1.0) -> void:
	RenderingServer.canvas_item_add_line(canvas_item, from, to, color, width)

func draw_segments():
	if segments.size() == 0:
		return
	# compute new history with history, tmp and new
	merge()

	# swap new and tmp, we don't need the old tmp anymore
	swap_rendering_items(RENDERING_ITEM.TMP_LINES, RENDERING_ITEM.NEW_LINES)


	# render a new "new"
	var canvas_item = canvas_list[RENDERING_ITEM.NEW_LINES].get_canvas_item()
	RenderingServer.canvas_item_clear(canvas_item)
	for segment in segments:
		var start = segment[0] - self.position
		var end = segment[1] - self.position
		var color = segment[2]
		var width = segment[3]

		render_server_add_line(canvas_item, start, end, color, width)
	RenderingServer.force_draw()

func darken(color : Color):
	var s = color.s
	var v = color.v
	s = BORNE_INF + (s-BORNE_INF)/DARK_COEF
	v = BORNE_INF + (v-BORNE_INF)/DARK_COEF

	return Color.from_hsv(color.h,s,v)

func _paint_with_width(pixel_position: Vector2, width: int, color: Color):
	var rect = Rect2(pixel_position - position, Vector2(width, width))

	#Si dans le basicColorImage on a déjà cette couleur, on fonce la couleur qu'on veut
	var basicColor : Color
	#Si on va appliquer une couleur qui est y déjà
	for x in range(width):
		for y in range(width):
			var pixelPoint = pixel_position-position + Vector2(x,y)
			if rectCheck.has_point(pixelPoint):
				basicColor = self.basicColorImage.get_pixelv(pixelPoint)
				var newColor = color
				if basicColor == color:
					newColor = darken(self.image.get_pixelv(pixelPoint))
				self.image.set_pixelv(pixelPoint,newColor)
	self.basicColorImage.fill_rect(rect, color)

var segments = []
