extends Button
class_name LevelButton

signal level_clicked(level: int)

var level_number: int

func init(level_data: LevelData, id_level: int):
	self.level_number = id_level
	self.text = 'Painting ' + str(level_number + 1) + ": " + level_data.name

func _on_pressed():
	emit_signal("level_clicked", self.level_number)
