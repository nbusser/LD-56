extends Node

signal end_of_level
signal game_over

var level_number
var nb_coins

@onready var hud = $UI/HUD


func _ready():
	hud.set_level_number(level_number)


func init(level_number, nb_coins):
	self.level_number = level_number


func _on_Timer_timeout():
	if randi() % 2:
		emit_signal("end_of_level")
	else:
		emit_signal("game_over")
