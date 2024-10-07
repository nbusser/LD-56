extends Control

signal next_level

var level_data: LevelData

@onready var level_label = $CenterContainer/VBoxContainer/CenterContainer/HBoxContainer/LevelNumber
@onready var coin_label = $CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer2/CoinsNumber


func _ready():
	assert(
		level_data != null,
		"init must be called before creating EndLevel scene"
	)
	level_label.text = str(level_data.number + 1)
	coin_label.text = str("NOT IMPLEMENTED")

func init(level_data):
	self.level_data = level_data


func _on_NextLevelButton_pressed():
	emit_signal("next_level")
