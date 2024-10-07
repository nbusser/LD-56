extends Control
class_name ScoreScreen

signal score_end

@onready var painting = $PaintingBackground/Painting
@onready var score_label = $TextPane/ScoreLabel
@onready var comment_label = $TextPane/CommentLabel

var level_data: LevelData
var painting_texture: Texture
var grade: float

var all_ratings = []
var comments = [
	"You did't even try...", # F
	"Size doesn't matter they said...", # E
	"Not bad... not good... NOT GOOD!", # D
	"You guys have to work on your coordination!", # C
	"Carry on pals!", # B
	"You are the firefly A team!", # A
	"Wait... which one is the original?" # S
]

func _score_to_note(score: float):
	print("Score", score)
	var n = all_ratings.size()
	var index = int(score * n)
	if index >= n:
		index = n - 1
	return all_ratings[index]

func _score_to_comment(score: float):
	print("Score", score)
	var n = comments.size()
	var index = int(score * n)
	if index >= n:
		index = n - 1
	return comments[index]
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	painting.texture = painting_texture
	$Model.texture = level_data.goal_texture

	$TextPane.visible = false
	score_label.visible = false
	comment_label.visible = false
	
	$Blackout.visible = true
	await create_tween().tween_property($Blackout, "modulate", Color.TRANSPARENT, 1).finished
	
	await get_tree().create_timer(1.0).timeout
	
	$TextPane.visible = true
	score_label.visible = true
	
	var ratings = ["F", "E", "D", "C", "B", "A", "S"]
	var modificators = ["-", " ", "+"]

	for rating in ratings:
		for mod in modificators:
			all_ratings.push_back(rating + mod)

	for i in range(randi() % 10 + 20):
		var fake_rating = ratings[randi()%ratings.size()] + modificators[randi()%modificators.size()]
		score_label.text = "Grade: " + _score_to_note(randf())
		await get_tree().create_timer(0.04).timeout
	await get_tree().create_timer(1.0).timeout
	
	score_label.text = "Grade: " + _score_to_note(grade)
	await get_tree().create_timer(1.0).timeout
	
	comment_label.text = _score_to_comment(grade)
	comment_label.visible = true
	await get_tree().create_timer(1.5).timeout
	
	await create_tween().tween_property($Blackout, "modulate", Color.BLACK, 1.5).finished
	await get_tree().create_timer(0.3).timeout

	emit_signal("score_end")

func init(level: LevelData, p_painting_texture: Image, p_grade:float):
	level_data = level
	painting_texture = ImageTexture.create_from_image(p_painting_texture)
	grade = p_grade

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
