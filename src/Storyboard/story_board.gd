extends Control

@onready var animated = $AnimatedSprite2D

signal start_game

func _ready():
	$Skip.modulate = Color.TRANSPARENT
	
	animated.play('default')
	animated.connect('animation_finished', self._on_animation_finished)

	await get_tree().create_timer(2.5).timeout
	create_tween().tween_property($Skip, "modulate", Color.WHITE, 2).finished
	
func _on_animation_finished():
	emit_signal("start_game")
	queue_free()

func _on_skip_pressed() -> void:
	emit_signal("start_game")
	queue_free()
