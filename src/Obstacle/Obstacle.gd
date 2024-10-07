extends Node2D
class_name Obstacle

func init(pos: Vector2, size: float) -> void:
	self.scale *= size
	self.position = pos

#If the animation is not playing when starting
#Add it on _ready . caimez
