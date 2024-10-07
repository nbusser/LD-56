extends Node2D

@onready var puddleScene = preload("res://src/PaintPuddle/PaintPuddle.tscn")
@onready var obstacleScene = preload("res://src/Obstacle/Obstacle.tscn")
@onready var painting = $Painting
@onready var model_texture = $Model/Texture
@onready var model_label = $Model/Name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func start_level_animation():
	$DarkLight.visible = true
	$ModelLight.visible = false
	$PaintingLight.visible = false

	await get_tree().create_timer(0.3).timeout
	await create_tween().tween_property($DarkLight, "energy", 0.85, 2.5).finished
	await get_tree().create_timer(1.0).timeout
	$ModelLight.visible = true
	$LightUp.play_sound() # TODO: PLACEHOLDER
	$Allelujah.play_sound() # TODO: PLACEHOLDER
	
	await get_tree().create_timer(1.5).timeout
	$PaintingLight.visible = true
	$LightUp.play_sound() # TODO: PLACEHOLDER
	

func start_level_animations_2():
	var paratween = create_tween()
	paratween.parallel().tween_property($DarkLight, "energy", 0.0, 1.0)
	paratween.parallel().tween_property($ModelLight, "energy", 0.0, 1.0)
	paratween.parallel().tween_property($PaintingLight, "energy", 0.0, 1.0)
	await paratween.finished

func add_puddle(puddle_data: PaintPuddleData):
	var newPuddle: PaintPuddle = puddleScene.instantiate()
	newPuddle.init(puddle_data.position, puddle_data.puddle_size, puddle_data.color, puddle_data.color_quantity, puddle_data.container_type)
	self.add_child(newPuddle)
	
func add_obstacle(obstacle_data : ObstacleData):
	var newObstacle : Obstacle = obstacleScene.instantiate()
	newObstacle.init(obstacle_data.position, obstacle_data.obstacle_size)
	$Obstacles.add_child(newObstacle)
	$Flock.obstacleList.append(newObstacle)
	

func set_model(model_name: String, model_texture: CompressedTexture2D):
	model_label.text = model_name
	self.model_texture.texture = model_texture

func _process(delta: float) -> void:
	pass

func get_score():
	return 1. - _compare_two_images(
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
			var pixelColor1 = image1.get_pixel(x, y)
			if pixelColor1.a < 0.5:
				pixelColor1 = Color(1, 1, 1)
			var pixelColor2 = image2.get_pixel(x, y)
			if pixelColor2.a < 0.5:
				pixelColor2 = Color(1, 1, 1)
			var hue1 = pixelColor1.h
			var hue2 = pixelColor2.h
			var hue_distance = min(abs(hue1 - hue2), 1.0 - abs(hue1 - hue2))
			if ((pixelColor1 == Color(1, 1, 1)) != (pixelColor2 == Color(1, 1, 1))):
				hue_distance = 1.0
			sum += hue_distance

	return sum / (image1.get_width() * image1.get_height())

func set_boundaries(value: bool):
	for shape in $ScreenBoundaries.get_children():
		shape.disabled = !value
