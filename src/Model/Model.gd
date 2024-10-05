extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var texture = $Area2D/Sprite2D.texture as CompressedTexture2D
	var image = texture.get_image()
	var pixel_array = []
	for y in range(image.get_height()):
		var px_row = [] 
		for x in range(image.get_width()):
			var color = image.get_pixel(x, y)
			px_row.append(color)
		pixel_array.append(px_row)
	var map_node = self.get_parent()
	map_node.model_array = pixel_array

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
