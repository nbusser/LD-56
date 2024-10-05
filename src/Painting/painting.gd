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

# Signal emited by Boid _process
# TODO: eventually add linear velocity to draw a quick line
func on_painting_drop(boid_position: Vector2, color: Color) -> void:
	var width = 2;
	for x in range(-width + 1, width):
		for y in range(-width + 1, width):
			var pixel_position = boid_position + Vector2(x, y)
			self.image.set_pixelv(pixel_position, color);
