extends Node2D
class_name PaintPuddle

var color : Color
var color_quantity = 100

func init(pos: Vector2, size: int, color: Color, quantity: int) -> void:
	self.scale *= size
	self.position = pos
	self.color = color
	self.modulate = color
	#Modulate the quantity depending on the quantity and the scaling
	#TODO CHANGE THE 3 DEPENDING ON THE SCALING OF THE ITEM
	#This will result in less paint from the start of the bidule
	self.color_quantity = quantity * size/5

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
