extends TextureRect
class_name Painting

@onready var canvas: CanvasItem = Node2D.new()
@onready var map = $".."
@onready var line: Line2D = Line2D.new()
@onready var paintingRect = Rect2(global_position, size)
@onready var surface_area = $PaintingArea/CollisionShape2D
@onready var rectCheck = Rect2(Vector2.ZERO,size)

var image: Image
var basicTexture
var basicColorImage : Image

func _ready():
	#reset(self.position, self.size);
	pass

func reset(painting_position: Vector2, painting_size: Vector2i):
	self.position = painting_position

	# Recreate an image with new dimensions
	self.image = Image.create(painting_size.x, painting_size.y, false, Image.FORMAT_RGBA8)
	self.image.fill(Color.WHITE)
	self.texture = ImageTexture.create_from_image(self.image)

	#The second image will be used for the tracking of the dark in the picture
	self.basicColorImage = Image.create(painting_size.x, painting_size.y, false, Image.FORMAT_RGBA8)
	self.basicColorImage.fill(Color.WHITE)
	#self.basicTexture = ImageTexture.create_from_image(self.basicColorImage)
	#$"../DebugPainting".texture = self.basicTexture
	# Also resize/shift the detection area
	var rect = RectangleShape2D.new()
	rect.size = painting_size
	self.surface_area.shape = rect
	self.surface_area.position = painting_size / 2.0

func _process(_delta):
	self.texture.update(self.image);
	#self.basicTexture.update(self.basicColorImage)
	rectCheck = Rect2(Vector2.ZERO,size)


func darken(color : Color):
	var s = color.s
	var v = color.v
	var BORNE_INF = 0.5
	var DARK_COEF = 1.01
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


# Signal emited by Boid _process
func on_painting_drop(boid_position: Vector2, boid_velocity: Vector2, color: Color, paint_level: int, delta) -> void:
	var currentPos = boid_position
	var precedentPos = boid_position - (boid_velocity * delta)
	var echantillon = (2 / delta)

	for index in range(1, echantillon):
		var interPos = precedentPos + (currentPos - precedentPos) * (index / echantillon)

		var width: int
		var n_splashes: int
		if paint_level > 75:
			width = 4
			n_splashes = randi() % 3
		elif paint_level > 50:
			width = 3
			n_splashes = randi() % 3
		else:
			width = 2
			n_splashes = randi() % 1

		# Drop paint in the exact position
		self._paint_with_width(interPos, width, color)

		# Eventually splashes the surroundings
		for s in range(n_splashes):
			var x_offset = randi() % 3 + width + 4
			x_offset = -x_offset if randi() else x_offset
			var y_offset = randi() % 3 + width + 4
			y_offset = -y_offset if randi() else y_offset
			var pixel_position = interPos + Vector2(x_offset, y_offset)
			var splash_width = width - 1
			#self._paint_with_width(pixel_position, splash_width, color)
