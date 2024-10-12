extends ReferenceRect

var level_data: LevelData
var user_texture: Texture2D
var grade_text: String

@onready var goal_texture_rect: TextureRect = %GoalTextureRect
@onready var user_texture_rect: TextureRect = %UserTextureRect
@onready var level_name_label: Label = %LevelNameLabel
@onready var grade_label: Label = %GradeLabel

func init(level_data: LevelData, user_texture: Texture2D, grade_text: String):
	self.level_data = level_data
	self.user_texture = user_texture
	self.grade_text = grade_text

func _ready() -> void:
	goal_texture_rect.texture = self.level_data.goal_texture
	user_texture_rect.texture = self.user_texture
	level_name_label.text = "Painting {0}: {1}".format([self.level_data.number + 1, self.level_data.name])
	grade_label.text = self.grade_text
