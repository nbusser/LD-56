extends Control
class_name ScoreScreen

signal score_end

@onready var painting = $PaintingBackground/Painting

var level_data: LevelData
var painting_texture: Texture
var grade: float

var all_ratings = []

func _score_to_note(score: float):
	print("Score", score)
	var n = all_ratings.size()
	var index = int(score * n)
	if index >= n:
		index = n - 1
	return all_ratings[index]
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	painting.texture = painting_texture
	$Model.texture = level_data.goal_texture

	$TextPane.visible = false
	$ScoreLabel.visible = false
	$CommentLabel.visible = false
	
	$Blackout.visible = true
	await create_tween().tween_property($Blackout, "modulate", Color.TRANSPARENT, 1).finished
	
	await get_tree().create_timer(1.0).timeout
	
	$TextPane.visible = true
	$ScoreLabel.visible = true
	
	var ratings = ["F", "E", "D", "C", "B", "A"]
	var modificators = ["-", " ", "+"]

	for rating in ratings:
		for mod in modificators:
			all_ratings.push_back(rating + mod)

	for i in range(randi() % 10 + 10):
		var fake_rating = ratings[randi()%ratings.size()] + modificators[randi()%modificators.size()]
		$ScoreLabel.text = _score_to_note(randf())
		await get_tree().create_timer(0.04).timeout
	
	$ScoreLabel.text = _score_to_note(grade)
	await get_tree().create_timer(2.0).timeout
	
	await create_tween().tween_property($Blackout, "modulate", Color.BLACK, 1).finished

	emit_signal("score_end")

func init(level: LevelData, p_painting_texture: Image, p_grade:float):
	level_data = level
	painting_texture = ImageTexture.create_from_image(p_painting_texture)
	grade = p_grade

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
