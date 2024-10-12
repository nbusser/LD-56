extends Control

class_name HowToPlay

func _on_start_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.HOW_TO_PLAY_FINISHED)
