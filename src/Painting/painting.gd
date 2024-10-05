extends TextureRect

@onready var canvas: CanvasItem = Node2D.new()
@onready var map = $"../../../Map"

var image: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)


@onready var line: Line2D = Line2D.new()

func _ready():
	self.image.fill(Color.WHITE)
	self.texture = ImageTexture.create_from_image(self.image)

func _process(_delta):
	self.texture.update(self.image);


func to_pack_vector2_array(array: Array[Vector2]) -> PackedVector2Array:
	return PackedVector2Array(array)

func _paint_with_width(pixel_position: Vector2, width: int, color: Color):
	for x in range(0,width):
		for y in range(0,width):
			if (x+y<width):
				self.image.set_pixelv(pixel_position + Vector2(x, y), color);
				self.image.set_pixelv(pixel_position + Vector2(-x, y), color);
				self.image.set_pixelv(pixel_position + Vector2(x, -y), color);
				self.image.set_pixelv(pixel_position + Vector2(-x, -y), color);

# Signal emited by Boid _process

# TODO: eventually add linear velocity to draw a quick line
func on_painting_drop(boid_position: Vector2, color: Color, paint_level: int) -> void:
	var width : int 
	var n_splashes = 0
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
	self._paint_with_width(boid_position, width, color)

	# Eventually splashes the surroundings
	for s in range(n_splashes):
		#caimez : For now I disabled this
		
		var x_offset = randi() % 3 + width + 2
		x_offset = -x_offset if randi() else x_offset
		var y_offset = randi() % 3 + width + 2
		y_offset = -y_offset if randi() else y_offset
		var pixel_position = boid_position + Vector2(x_offset, y_offset)

		var splash_width = width - 1
		self._paint_with_width(pixel_position, splash_width, color)

func draw_line_on_image(img: Image, start: Vector2, end: Vector2, color: Color) -> void:
	pass
