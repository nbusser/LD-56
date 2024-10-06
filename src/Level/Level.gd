extends Node

signal end_of_level
signal game_over

var level_data: LevelData

@onready var hud = $UI/HUD

func _ready():
	hud.set_level_number(level_data.number)
	hud.set_goal(level_data.goal_texture)


func init(level_data: LevelData):
	self.level_data = level_data


func _on_Timer_timeout():
	if randi() % 2:
		emit_signal("end_of_level")
	else:
		emit_signal("game_over")
