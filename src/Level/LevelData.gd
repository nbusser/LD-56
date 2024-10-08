extends Resource
class_name LevelData

@export var flock_size: int
@export var name: String
@export var goal_texture: CompressedTexture2D
@export var canvas_position: Vector2
@export var canvas_size: Vector2
@export var time_limit: float
@export var puddles: Array[PaintPuddleData]
@export var show_cutscene: bool = true
@export var obstacles : Array[ObstacleData]

# Set dynamically
var number: int
