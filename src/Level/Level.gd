extends Node

signal end_of_level
signal game_over

var level_data: LevelData

@onready var hud = $UI/HUD
@onready var map = $Map
@onready var flock: Flock = $Map/Flock
@onready var end_of_level_target: Node2D = $Map/EndOfLevelTarget
@onready var painting: Painting = $Map/Painting
@onready var timer = $Timer

func _ready():
	timer.start(level_data.time_limit)
	
	for puddle in self.level_data.puddles:
		map.add_puddle(puddle)
		
	painting.reset(level_data.canvas_position, level_data.canvas_size)
	map.set_model(level_data.name, level_data.goal_texture)

func _process(delta: float) -> void:
	hud.update_timer(timer.time_left)


func init(level: LevelData):
	self.level_data = level


func _on_Timer_timeout():
	var score = map.get_score()
	flock.stop_following_mouse(end_of_level_target.position)
	await hud.time_up(score)

	if randi() % 2:
		emit_signal("end_of_level")
	else:
		emit_signal("game_over")
