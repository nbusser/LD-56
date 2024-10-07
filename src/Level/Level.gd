extends Node

signal end_of_level(Image, float)
signal game_over

var level_data: LevelData

@onready var hud = $UI/HUD
@onready var map = $Map
@onready var flock: Flock = $Map/Flock
@onready var start_of_level_target: Node2D = $Map/StartOfLevelTarget
@onready var end_of_level_target: Node2D = $Map/EndOfLevelTarget
@onready var painting: Painting = $Map/Painting
@onready var timer = $Timer

func _ready():
	hud.update_timer(level_data.time_limit)
	
	flock.spawn(level_data.flock_size)
	
	for puddle in self.level_data.puddles:
		map.add_puddle(puddle)
		
	painting.reset(level_data.canvas_position, level_data.canvas_size)
	map.set_model(level_data.name, level_data.goal_texture)

	# Map anim
	await map.start_level_animation()

	# Run flock
	flock.stop_following_mouse(start_of_level_target.position)
	map.set_boundaries(false)
	flock.set_active(true)
	await get_tree().create_timer(1.0).timeout

	# Game starts for real
	map.set_boundaries(true)
	flock.start_following_mouse()
	
	timer.start(level_data.time_limit)


func _process(delta: float) -> void:
	if not timer.is_stopped():
		hud.update_timer(timer.time_left)


func init(level: LevelData):
	self.level_data = level


func _on_Timer_timeout():
	var score = map.get_score()
	flock.stop_following_mouse(end_of_level_target.position)
	map.set_boundaries(false)

	await hud.time_up(score)

	emit_signal("end_of_level", painting.texture.get_image(), score)
	#emit_signal("game_over")
