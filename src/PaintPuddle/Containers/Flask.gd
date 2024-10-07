extends Node2D

@onready var paint_vapor: PaintVapor = $PaintVapor
@onready var flask_mg: AnimatedSprite2D = $FlaskMg

@export_color_no_alpha var color : Color = Color.WHITE:
	get():
		return color
	set(value):
		paint_vapor.color = value
		flask_mg.modulate = value
		color = value
