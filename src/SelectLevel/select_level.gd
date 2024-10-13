extends Control

class_name SelectLevel

@onready var level_list = $PanelContainer/HBoxContainer/VBoxContainer/LevelList
@onready var level_btn = preload("res://src/SelectLevel/level_button.tscn")

var levels: Array[LevelData]

func _ready():
	for i in range(levels.size()):
		var level_btn_instance: LevelButton = level_btn.instantiate()
		level_btn_instance.init(levels[i], i)
		level_btn_instance.level_clicked.connect(self._selected)
		level_list.add_child(level_btn_instance)

func init(data: Array[LevelData]):
	self.levels = data

func _selected(level):
	Globals.end_scene(Globals.EndSceneStatus.SELECT_LEVEL_SELECTED, {
		"level_i": level
	})

func _on_back_pressed():
	Globals.end_scene(Globals.EndSceneStatus.SELECT_LEVEL_BACK)
