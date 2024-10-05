extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Transfer right now the image to the map 
	var map_node = self.get_parent()
	var texture = $Area2D/Sprite2D.texture as CompressedTexture2D
	map_node.model_image = texture.get_image()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
