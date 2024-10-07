@tool

extends Node2D

@onready var paint_vapor: PaintVapor = $PaintVapor
@onready var flask_2_mg: AnimatedSprite2D = $Flask2Mg

@export_color_no_alpha var color : Color = Color.WHITE:
	get():
		return color
	set(value):
		paint_vapor.color = value
		flask_2_mg.modulate = value
		color = value
