extends Control
class_name ScoreScreen

signal score_end

@onready var painting = $PaintingBackground/Painting

var painting_texture: Texture
var model_texture: Texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	painting.texture = painting_texture
	$Model.texture = model_texture

	$Blackout.visible = true
	await create_tween().tween_property($Blackout, "modulate", Color.TRANSPARENT, 1).finished
		
	await get_tree().create_timer(2.0).timeout
	emit_signal("score_end")

func init(level: LevelData, p_painting_texture: Image):
	painting_texture = ImageTexture.create_from_image(p_painting_texture)
	model_texture = level.goal_texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
