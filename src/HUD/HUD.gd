extends Control

@onready var timer_value: Label = %TimerValue
@onready var clock_short: Sprite2D = %ClockShort
@onready var clock_long: Sprite2D = %ClockLong

@onready var time_up_panel = $TimeIsUp
@onready var time_up_label = $TimeIsUp/TimeIsUpLabel

@onready var fadeout_pane = $FadeOutPane

func update_timer(time_left: float) -> void:
	var time_left_int = int(time_left)
	timer_value.text = str(floor(time_left_int / 60)).pad_zeros(2) + ":" + str(time_left_int % 60).pad_zeros(2)
	clock_short.rotation_degrees = time_left_int / 60 * 6
	clock_long.rotation_degrees = time_left_int % 60 * 6

func time_up():
	time_up_panel.visible = 1
	
	time_up_panel.modulate = Color.TRANSPARENT
	
	fadeout_pane.modulate = Color.TRANSPARENT
	fadeout_pane.visible = 1

	await create_tween().tween_property(time_up_panel, "modulate", Color.WHITE, 0.3).finished
	await get_tree().create_timer(2.0).timeout
	time_up_panel.visible = 0
	
	await create_tween().tween_property(fadeout_pane, "modulate", Color.BLACK, 1).finished
	await get_tree().create_timer(0.5).timeout


func _on_reset_button_button_down() -> void:
	var sm = get_parent().get_parent().get_parent().get_parent().get_parent()
	sm._load_level()
