extends Node2D
class_name PaintPuddle

@export var color = Color(255, 0, 0, 1)
@export var color_quantity = 100
@export var puddleSize = 1
@export var puddlePos: Vector2 = Vector2(0, 0)


func init(pos: Vector2, size: int, color: Color = Color(255, 0, 0, 1)) -> void:
	self.puddleSize = size
	self.puddlePos = pos
	self.color = color
	self.modulate = color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale *= self.puddleSize
	position = self.puddlePos
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
