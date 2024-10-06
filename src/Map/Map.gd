extends Node2D

@onready var puddleScene = preload("res://src/PaintPuddle/PaintPuddle.tscn")
@onready var painting = $Painting
@onready var model_texture = $Model/Texture
@onready var model_label = $Model/Name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func add_puddle(puddle_data: PaintPuddleData):
	var newPuddle: PaintPuddle = puddleScene.instantiate()
	newPuddle.init(puddle_data.position, puddle_data.puddle_size, puddle_data.color, puddle_data.color_quantity)
	self.add_child(newPuddle)

func set_model(model_name: String, model_texture: CompressedTexture2D):
	model_label.text = model_name
	self.model_texture.texture = model_texture

func _process(delta: float) -> void:
	pass

func get_score():
	return _compare_two_images(
		painting.texture.get_image(),
		model_texture.texture.get_image()
	)

# This fonction compare two images and return a value
func _compare_two_images(image1: Image, image2: Image) -> float:
	image1.resize(min(image1.get_width(), image2.get_width()), min(image1.get_height(), image2.get_height()))
	image2.resize(min(image1.get_width(), image2.get_width()), min(image1.get_height(), image2.get_height()))
	var sum: float = 0.0
	for y in range(image1.get_height()):
		for x in range(image1.get_width()):
			#Run distance_squared cause it is faster (source:godot doc)
			var pixelColor1 = image1.get_pixel(x, y)
			var pixelVector1 = Vector3(pixelColor1.r, pixelColor1.g, pixelColor1.b)
			var pixelColor2 = image2.get_pixel(x, y)
			var pixelVector2 = Vector3(pixelColor2.r, pixelColor2.g, pixelColor2.b)
			sum += pixelVector1.distance_squared_to(pixelVector2)
	
	#Plus la note est éloignée de 0, moins c'est bien
	#On divise par 3 pour normaliser en 3D
	return sum / (3 * (image1.get_width() * image1.get_height()))
