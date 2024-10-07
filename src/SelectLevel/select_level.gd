extends Control

signal level_selected(level: int)
signal back()

@onready var level_list = $PanelContainer/HBoxContainer/VBoxContainer/LevelList
@onready var level_btn = preload("res://src/SelectLevel/level_button.tscn")

var levels: Array[LevelData]

func _ready():
	for i in range(levels.size()):
		var level_btn_instance: LevelButton = level_btn.instantiate()
		level_btn_instance.init(levels[i], i)
		level_btn_instance.connect('level_clicked', self._selected)
		level_list.add_child(level_btn_instance)

func init(data: Array[LevelData]):
	self.levels = data

func _selected(level):
	emit_signal("level_selected", level)
	queue_free()

func _on_back_pressed():
	emit_signal("back")
	queue_free()
