extends Node

signal end_of_level
signal game_over

var level_data: LevelData

@onready var hud = $UI/HUD
@onready var map = $Map
@onready var timer = $Timer

func _ready():
	hud.set_level_name(level_data.name)
	hud.set_goal(level_data.goal_texture)
	map.model_image = level_data.goal_texture.get_image()
	timer.start(level_data.time_limit)

func _process(delta: float) -> void:
	hud.update_timer(timer.time_left)


func init(level: LevelData):
	self.level_data = level


func _on_Timer_timeout():
	if randi() % 2:
		emit_signal("end_of_level")
	else:
		emit_signal("game_over")
