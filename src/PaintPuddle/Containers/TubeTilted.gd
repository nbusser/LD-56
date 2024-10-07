extends Node2D

@onready var paint_vapor: PaintVapor = $PaintVapor
@onready var tube_mg_tilted: Sprite2D = $TubeMgTilted

@export_color_no_alpha var color : Color = Color.WHITE:
	get():
		return color
	set(value):
		paint_vapor.color = value
		tube_mg_tilted.modulate = value
		color = value
