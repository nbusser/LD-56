extends Node2D

@onready var paint_vapor: PaintVapor = $PaintVapor
@onready var cauldron_mg: AnimatedSprite2D = $CauldronMg

@export_color_no_alpha var color : Color = Color.WHITE:
	get():
		return color
	set(value):
		paint_vapor.color = value
		cauldron_mg.modulate = value
		color = value
