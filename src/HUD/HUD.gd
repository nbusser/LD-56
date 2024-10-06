extends Control

@onready var timer_value = $Timer/TimerValue
@onready var time_up_label = $TimeIsUp
@onready var fadeout_pane = $FadeOutPane

func update_timer(time_left: float) -> void:
	var time_left_int = int(time_left)
	timer_value.text = str(floor(time_left_int / 60)).pad_zeros(2) + " : " + str(time_left_int % 60).pad_zeros(2)

func time_up():
	time_up_label.modulate = Color.TRANSPARENT
	time_up_label.visible = 1

	fadeout_pane.modulate = Color.TRANSPARENT
	fadeout_pane.visible = 1

	await create_tween().tween_property(time_up_label, "modulate", Color.WHITE, 0.3).finished
	await get_tree().create_timer(1.0).timeout
	await create_tween().tween_property(fadeout_pane, "modulate", Color.BLACK, 1).finished
	await get_tree().create_timer(0.5).timeout
