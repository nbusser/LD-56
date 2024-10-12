extends Node

class_name Level

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
	#Random below
	#for i in range(0):
	#	var puddle = PaintPuddleData.new()
	#	puddle.color = [Color.FIREBRICK, Color.GOLD, Color.LIGHT_GREEN, Color.BLUE_VIOLET, Color.ROYAL_BLUE].pick_random()
	#	puddle.container_type = PaintPuddle.ContainerType.values().pick_random()
	#	puddle.position = Vector2((randf()-0.5)*1000, (randf()-0.5)*1000)
	#	puddle.puddle_size = 1
	#	puddle.color_quantity = 1
	#	map.add_puddle(puddle)

	for puddle in self.level_data.puddles:
		map.add_puddle(puddle)
		
	painting.reset(level_data.canvas_position, level_data.canvas_size)
	map.set_model(level_data.name, level_data.goal_texture)
	
	#Obstacles
	for obstacle in self.level_data.obstacles:
		map.add_obstacle(obstacle)
	# Map anim
	# Map anim 1

	var anim_duration_factor = 1.0 if level_data.show_cutscene else 0.5
	await map.start_level_animation(anim_duration_factor)

	# Run flock
	flock.stop_following_mouse(start_of_level_target.position)
	map.set_boundaries(false)
	flock.set_active(true)
	await get_tree().create_timer(4.0 * anim_duration_factor).timeout
	
	# Map anim 2
	await map.start_level_animations_2(anim_duration_factor)

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
	$TimesUpSound.play_sound()
	var score = map.get_score()
	flock.stop_following_mouse(end_of_level_target.position)
	map.set_boundaries(false)

	await hud.time_up()

	Globals.end_scene(Globals.EndSceneStatus.LEVEL_END, {
		"image": painting.texture.get_image(),
		"score": score
	})
