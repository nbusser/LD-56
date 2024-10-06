extends Control

@onready var level_label = $VBoxContainer/VBoxContainer/LevelNumber/LevelNumberValue


func set_level_number(level_number):
	level_label.text = str(level_number + 1)

func set_goal(compressed_texture: CompressedTexture2D):
	#TODO
	pass
