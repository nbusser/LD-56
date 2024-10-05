extends CharacterBody2D
class_name Boid

var max_speed := 200.0

# Force factors
var mouse_follow_force := 0.05
var cohesion_force := 0.05
var algin_force := 0.05
var repulsion_force := 0.05

# Ranges
var view_range := 50.0
var repulsion_range := 20.0

@onready var flock := $"../.." as Flock

func _ready() -> void:
	pass

func calculate_forces() -> Dictionary:
	# Get fellow boids within view range
	var neighbours: Array[Boid] = flock.get_neighbour_boids(self)

	# No neighbours
	if neighbours.is_empty():
		return {
			"cohesion": Vector2(),
			"repulsion": Vector2(),
		};

	# Center of local flock, in POV of boid
	var center = Vector2();
	# Vector to get repulsed from neighbours being too near
	var repulsion_vector = Vector2();

	for neighbour in neighbours:
		center += neighbour.global_position

		var distance_to_neighbour = global_position.distance_squared_to(neighbour.global_position)
		if distance_to_neighbour < repulsion_range:
			repulsion_vector -= (
				(neighbour.global_position - global_position).normalized() *
				(repulsion_range / (distance_to_neighbour if distance_to_neighbour != 0 else 0.01) * max_speed) # The closer, the harder it repulses
			)
			pass

	center /= neighbours.size();

	# Vector to get closer to the local center
	var cohesion_vector = global_position.direction_to(center).normalized();

	return {
		"cohesion": cohesion_vector * cohesion_force,
		"repulsion": repulsion_vector * repulsion_force,
	};

func _process(delta: float) -> void:
	var sum_forces = calculate_forces().values().reduce(func(acc, val): return acc + val)

	velocity += (sum_forces * delta)

	move_and_slide()
