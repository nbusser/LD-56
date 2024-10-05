extends CharacterBody2D
class_name Boid

@export var max_speed := 200.0
@export var mouse_follow_force := 0.05
@export var cohesion_force := 0.05
@export var algin_force := 0.05
@export var separation_force := 0.05
@export var view_range := 50.0

@onready var flock := $"../.." as Flock

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func calculate_forces() -> Vector2:
	# Get fellow boids within view range
	var neighbours: Array[Boid] = flock.get_neighbour_boids(self)

	# No neighbours
	if neighbours.is_empty():
		return Vector2();

	var center = Vector2();

	for neighbour in neighbours:
		center += neighbour.global_position;

	center /= neighbours.size();

	var center_vector = global_position.direction_to(center).normalized();

	return center_vector;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var center_vector = flock.calculate_boid_context(self);

	# Will drag the boid toward the center of the flock
	var cohesion_vector = center_vector * cohesion_force;

	var move_vector = cohesion_vector

	move_and_collide(move_vector, delta)
	pass
