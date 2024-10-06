@tool

extends Node2D
class_name PaintVapor

@export_color_no_alpha var color : Color = Color.WHITE:
	get():
		return color
	set(value):
		self._on_update_color(value)
		color = value
var color_quantity = 100

@onready var bubbles = $Bubbles
@onready var smoke = $Smoke

func init(pos: Vector2, size: int, color: Color, quantity: int) -> void:
	self.scale *= size
	self.position = pos
	self.color = color
	self.color_quantity = quantity

func _ready() -> void:
	_on_update_color(self.color)

func _on_update_color(value: Color):
	if bubbles:
		bubbles.modulate = color.lightened(0.2)
		bubbles.modulate.a = 0.8
	if smoke:
		smoke.modulate = color.lightened(0.2)
		smoke.modulate.a = 0.3
	
