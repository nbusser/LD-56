extends Node2D

var model_image : Image
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print(compare_two_images(model_image,model_image))
	pass	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# This fonction compare two images and return a value
func compare_two_images(image1 : Image, image2 : Image) -> int :
	var DIFFERENCE_PRECISION = 100
	image1.resize(min(image1.get_width(),image2.get_width()),min(image1.get_height(),image2.get_height()))
	image2.resize(min(image1.get_width(),image2.get_width()),min(image1.get_height(),image2.get_height()))
	var distancePbP : Array
	for y in range(image1.get_height()):
		for x in range(image1.get_width()):
			#Run distance_squared cause it is faster (source:godot doc)
			var pixelColor1 = image1.get_pixel(x,y)
			var pixelVector1 : Vector3 = Vector3(pixelColor1.r*DIFFERENCE_PRECISION,pixelColor1.g*DIFFERENCE_PRECISION,pixelColor1.b*DIFFERENCE_PRECISION)
			var pixelColor2 = image1.get_pixel(x,y)
			var pixelVector2 : Vector3 = Vector3(pixelColor2.r*DIFFERENCE_PRECISION,pixelColor2.g*DIFFERENCE_PRECISION,pixelColor2.b*DIFFERENCE_PRECISION)
			distancePbP.append(pixelVector1.distance_squared_to(pixelVector2))
	var sum : int
	for i in distancePbP : sum+= i
	#Plus la note est éloignée de 0, moins c'est bien
	#La pire note c'est 3*DIFFERENCE_PRECISION**2
	return sum/len(distancePbP)
	
