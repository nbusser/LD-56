extends TextureRect

@onready var canvas: CanvasItem = Node2D.new()
@onready var map = $"../../../Map"


const CANVAS_SIZE = 100

var image: Image = Image.create(CANVAS_SIZE, CANVAS_SIZE, false, Image.FORMAT_RGBA8)


@onready var line: Line2D = Line2D.new()

func _ready():
	self.image.fill(Color.WHITE)
	self.texture = ImageTexture.create_from_image(self.image)

func _process(_delta):
	self.texture.update(self.image);


func to_pack_vector2_array(array: Array[Vector2]) -> PackedVector2Array:
	return PackedVector2Array(array)

func _paint_with_width(width: int, position: Vector2, color: Color):
	for x in range(-width + 1, width):
		for y in range(-width + 1, width):
			var pixel_position = position + Vector2(x, y)
			self.image.set_pixelv(pixel_position, color);

# Signal emited by Boid _process
# TODO: eventually add linear velocity to draw a quick line
func on_painting_drop(boid_position: Vector2, color: Color, paint_level: int) -> void:
	var width = 1
	var n_splashes = 0
	if paint_level > 75:
		width = 3
		n_splashes = randi() % 3
	elif paint_level > 50:
		width = 2
		n_splashes = randi() % 3
	else:
		width = 1
		n_splashes = randi() % 1

	self._paint_with_width(width, boid_position, color)


	for s in range(n_splashes):
		var x_offset = randi() % 3 + width + 2
		x_offset = -x_offset if randi() else x_offset
		var y_offset = randi() % 3 + width + 2
		y_offset = -y_offset if randi() else y_offset
		var pixel_position = boid_position + Vector2(x_offset, y_offset)

		var splash_width = width if width <= 1 else width - 1
		self._paint_with_width(splash_width, pixel_position, color)
