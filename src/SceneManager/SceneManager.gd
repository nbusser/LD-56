extends Control

@export var levels: Array[LevelData]
var current_level_number = 0

var current_player: AudioStreamPlayer
var current_scene: set = set_scene

@onready var music_players = $Musics.get_children() as Array[AudioStreamPlayer]

@onready var main_menu = preload("res://src/MainMenu/MainMenu.tscn")
@onready var level = preload("res://src/Level/Level.tscn")
@onready var change_level = preload("res://src/EndLevel/EndLevel.tscn")
@onready var credits = preload("res://src/Credits/Credits.tscn")
@onready var intro = preload("res://src/Storyboard/StoryBoard.tscn")
@onready var game_over = preload("res://src/GameOver/GameOver.tscn")
@onready var select_level = preload("res://src/SelectLevel/select_level.tscn")
@onready var score_screen = preload("res://src/ScoreScreen/ScoreScreen.tscn")

@onready var viewport = $SubViewportContainer/SubViewport


# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in range(levels.size()):
		levels[i].number = i

	randomize()
	_run_main_menu()


func _process(_delta):
	if Input.is_action_pressed("quit"):
		get_tree().quit()


func _on_quit_game():
	get_tree().quit()


func _on_start_game():
	change_music_track(music_players[0])
	_load_level()


func _on_show_credits():
	_run_credits(true)

func _on_show_intro():
	_run_intro()

func _on_show_main_menu():
	_run_main_menu()


func set_scene(new_scene):
	if current_scene:
		viewport.remove_child(current_scene)
		current_scene.queue_free()

	current_scene = new_scene
	viewport.add_child(current_scene)


func _load_level():
	var scene = level.instantiate()
	scene.init(levels[current_level_number])

	scene.connect("end_of_level", Callable(self, "_on_end_of_level"))
	scene.connect("game_over", Callable(self, "_on_game_over"))

	self.current_scene = scene


func _on_end_of_level(painting: Image, score: float):
	var scene: ScoreScreen = score_screen.instantiate()
	scene.init(levels[current_level_number], painting, score)

	scene.connect("score_end", Callable(self, "_on_next_level"))
	
	self.current_scene = scene


func _on_game_over():
	var scene = game_over.instantiate()

	scene.connect("restart", Callable(self, "_on_restart_level"))
	scene.connect("quit", Callable(self, "_on_quit_game"))

	self.current_scene = scene


func _on_restart_level():
	_load_level()


func _on_restart_select_level():
	_load_end_level()


func _load_end_level():
	var scene = change_level.instantiate()
	scene.init(levels[current_level_number])

	scene.connect("next_level", Callable(self, "_on_next_level"))

	self.current_scene = scene


func _on_next_level():
	if current_level_number + 1 >= levels.size():
		# Win
		_run_credits(false)
	else:
		current_level_number += 1
		change_music_track(music_players[current_level_number % len(music_players)])
		_load_level()


func _run_credits(can_go_back):
	var scene = credits.instantiate()

	scene.set_back(can_go_back)
	if can_go_back:
		scene.connect("back", Callable(self, "_on_show_main_menu"))

	self.current_scene = scene


func _run_intro():
	var scene = intro.instantiate()
	scene.connect("start_game", Callable(self, "_on_start_game"))
	self.current_scene = scene

func _run_main_menu():
	var scene = main_menu.instantiate()

	change_music_track(music_players[music_players.size() - 1])

	scene.connect("quit_game", Callable(self, "_on_quit_game"))
	scene.connect("show_intro", Callable(self, "_on_show_intro"))
	scene.connect("show_credits", Callable(self, "_on_show_credits"))
	scene.connect("select_level", Callable(self, "_on_select_level"))

	self.current_scene = scene


func change_music_track(new_player: AudioStreamPlayer):
	if current_player != new_player:
		for mp in music_players:
			mp.stop()

		new_player.play()
		current_player = new_player

func _run_select_level():
	var scene = select_level.instantiate()
	
	scene.init(levels)
	scene.connect("level_selected", Callable(self, "_on_level_selected"))
	scene.connect("back", Callable(self, "_run_main_menu"))

	self.current_scene = scene

func _on_select_level():
	_run_select_level()

func _on_level_selected(level):
	current_level_number = level - 1
	_on_next_level()
