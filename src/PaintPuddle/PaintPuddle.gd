extends Node2D
class_name PaintPuddle

var color = Color(255, 0, 0, 1)
var color_quantity = 100

func init(pos: Vector2, size: int, color: Color, quantity: int) -> void:
	self.scale *= size
	self.position = pos
	self.color = color
	self.modulate = color
	self.color_quantity = quantity

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
