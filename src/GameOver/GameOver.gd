extends Control

func _on_Restart_pressed():
	Globals.end_scene(
		Globals.EndSceneStatus.GAME_OVER_RESTART
	)


func _on_Quit_pressed():
	Globals.end_scene(
		Globals.EndSceneStatus.GAME_OVER_QUIT
	)
