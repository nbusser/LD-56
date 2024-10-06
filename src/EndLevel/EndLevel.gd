extends Control

signal next_level

var level_number

@onready var level_label = $CenterContainer/VBoxContainer/CenterContainer/HBoxContainer/LevelNumber
@onready var coin_label = $CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer2/CoinsNumber


func _ready():
	assert(
		level_number != null,
		"init must be called before creating EndLevel scene"
	)
	level_label.text = str(level_number + 1)
	coin_label.text = str("NOT IMPLEMENTED")

func init(level_number):
	self.level_number = level_number


func _on_NextLevelButton_pressed():
	emit_signal("next_level")
