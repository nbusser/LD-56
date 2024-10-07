extends Control

@onready var animated = $AnimatedSprite2D

signal start_game

func _ready():
	animated.play('default')
	animated.connect('animation_finished', self._on_animation_finished)

func _on_animation_finished():
	print('finished')
	emit_signal("start_game")
	queue_free()
