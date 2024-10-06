extends Control

@onready var level_label = $VBoxContainer2/MarginContainer/LevelName
@onready var goal_texture = $VBoxContainer2/CenterContainer/GoalTexture
@onready var timer_value = $VBoxContainer2/MarginContainer2/Timer/TimerValue
@onready var timer = $VBoxContainer2/MarginContainer2/Timer/Timer

func set_level_name(level_name):
	level_label.text = str(level_name)

func set_goal(compressed_texture: CompressedTexture2D):
	goal_texture.texture = compressed_texture

func update_timer(time_left: float) -> void:
	var time_left_int = int(time_left)
	timer_value.text = str(floor(time_left_int / 60)).pad_zeros(2) + " : " + str(time_left_int % 60).pad_zeros(2)
