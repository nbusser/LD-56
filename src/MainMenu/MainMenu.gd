extends Control

signal show_credits
signal show_tuto
signal quit_game
signal select_level

func _ready():
	$Splash/AnimationPlayer.play("cloud")


func _on_Start_pressed():
	emit_signal("show_tuto")
	queue_free()

func _on_Credits_pressed():
	emit_signal("show_credits")
	queue_free()

func _on_Quit_pressed():
	emit_signal("quit_game")
	queue_free()


func _on_select_level_pressed() -> void:
	emit_signal("select_level")
	queue_free()
