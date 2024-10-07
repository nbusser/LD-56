extends Node2D
class_name PaintVapor

@export_color_no_alpha var color : Color = Color.WHITE:
	get():
		return color
	set(value):
		self._on_update_color(value)
		color = value

@onready var bubbles = $Bubbles
@onready var smoke = $Smoke

func _ready() -> void:
	call_deferred("_on_update_color", self.color)

func _on_update_color(value: Color):
	if bubbles:
		bubbles.modulate = color.lightened(0.2)
		bubbles.modulate.a = 0.8
	if smoke:
		smoke.modulate = color.lightened(0.2)
		smoke.modulate.a = 0.3
	
