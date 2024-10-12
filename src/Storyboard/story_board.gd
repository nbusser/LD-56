extends Control

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated2: AnimatedSprite2D = $AnimatedSprite2D2
@onready var black_rect: ColorRect = $BlackRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal storyboard_finished

func _ready():
	$Skip.modulate = Color.TRANSPARENT
	black_rect.show()
	black_rect.modulate = Color.WHITE
	await create_tween().tween_property(black_rect, "modulate", Color.TRANSPARENT, 2).finished
	animation_player.play("animated_sprite_opacity")
	
	animated2.play('default')
	await get_tree().create_timer(1).timeout
	animated.play('default')
	
	animated.connect('animation_finished', self._on_animation_finished)

	await get_tree().create_timer(2.5).timeout
	create_tween().tween_property($Skip, "modulate", Color.WHITE, 2)
	
func _on_animation_finished():
	await create_tween().tween_property(black_rect, "modulate", Color.WHITE, 2).finished
	emit_signal("storyboard_finished")
	queue_free()

func _on_skip_pressed() -> void:
	emit_signal("storyboard_finished")
	queue_free()
