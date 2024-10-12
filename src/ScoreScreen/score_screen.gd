extends Control
class_name ScoreScreen

signal score_end_next
signal score_end_restart
signal score_end_back_select

@onready var painting = $BackgroundPane/PaintingBackground/Painting
@onready var model = $BackgroundPane/Model

@onready var text_pane = $TextPane
@onready var score_label = $TextPane/ScoreLabel
@onready var comment_label = $TextPane/CommentLabel

@onready var buttons = $Buttons

var level_data: LevelData
var painting_texture: Texture
var grade: float
var from_level_selector: bool 

var all_ratings = []
var comments = [
	"You didn't even try...", # F
	"Size doesn't matter they said...", # E
	"Not bad... not good... NOT GOOD!", # D
	"You guys have to work on your coordination!", # C
	"Carry on pals!", # B
	"You are the firefly A team!", # A
	"Wait... which one is the original?" # S
]

func _score_to_note(score: float):
	var n = all_ratings.size()
	var index = int(score * n)
	if index >= n:
		index = n - 1
	return all_ratings[index]

func _score_to_comment(score: float):
	var n = comments.size()
	var index = int(score * n)
	if index >= n:
		index = n - 1
	return comments[index]
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	painting.texture = painting_texture
	model.texture = level_data.goal_texture

	text_pane.visible = false
	score_label.visible = false
	comment_label.visible = false
	
	# Disable buttons depending on the game flow (level selector or normal game)
	$Buttons.visible = false
	$Buttons/Next.visible = !from_level_selector
	#$Buttons/Restart.visible = !from_level_selector
	$Buttons/BackLevelSelector.visible = from_level_selector
	
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

	$Drums.play_sound()
	for i in range(55):
		var fake_rating = ratings[randi()%ratings.size()] + modificators[randi()%modificators.size()]
		score_label.text = "Grade: " + _score_to_note(randf())
		await get_tree().create_timer(0.04).timeout
	await get_tree().create_timer(1.0).timeout
	
	#$Whoah.play_sound()
	var strnote = _score_to_note(grade)
	if strnote == "A" or strnote == "A+" or strnote == "A-":
		$A.play_sound() 
	elif strnote == "B" or strnote == "B+" or strnote == "B-":
		$B.play_sound() 
	elif strnote == "C" or strnote == "C+" or strnote == "C-":
		$C.play_sound() 
	if strnote == "D" or strnote == "D+" or strnote == "D-":
		$D.play_sound() 
	$Tick.play_sound()
	score_label.text = "Grade: " + _score_to_note(grade)
	await get_tree().create_timer(1.0).timeout
	
	$Tick.play_sound()
	comment_label.text = _score_to_comment(grade)
	comment_label.visible = true
	await get_tree().create_timer(1.5).timeout
	
	$Tick.play_sound()
	$Buttons.visible = true

func init(level: LevelData, p_painting_texture: Image, p_grade:float, comes_from_level_selector: float):
	level_data = level
	painting_texture = ImageTexture.create_from_image(p_painting_texture)
	grade = p_grade
	from_level_selector = comes_from_level_selector

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_next_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.SCORE_SCREEN_NEXT)

func _on_restart_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.SCORE_SCREEN_RETRY)

func _on_back_level_selector_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.SCORE_SCREEN_BACK)


func _on_save_pressed() -> void:
	_save_image()

func _save_image() -> void:
	var image = await ImageExportManager.create_end_level_image(painting_texture, level_data, _score_to_note(grade))
	ImageExportManager.save_image(image, "fluffy-flock-painting-{0}".format([level_data.number + 1]))
