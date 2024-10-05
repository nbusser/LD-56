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
		return {};

	# Center of local flock, in POV of boid
	var center = Vector2();
	# Vector to get repulsed from neighbours being too near
	var repulsion_vector = Vector2();

	var align_vector = Vector2();

	for neighbour in neighbours:
		center += neighbour.global_position

		var distance_to_neighbour = global_position.distance_squared_to(neighbour.global_position)
		if distance_to_neighbour < repulsion_range:
			repulsion_vector -= (
				(neighbour.global_position - global_position).normalized() *
				(repulsion_range / (distance_to_neighbour if distance_to_neighbour != 0 else 0.01) * max_speed) # The closer, the harder it repulses
			)
			pass
		
		align_vector += neighbour.velocity

	center /= neighbours.size();
	align_vector /= neighbours.size();

	# Vector to get closer to the local center
	var cohesion_vector = global_position.direction_to(center);

	return {
		"cohesion": cohesion_vector.normalized() * cohesion_force,
		"repulsion": repulsion_vector.normalized() * repulsion_force,
		"align": align_vector.normalized() * algin_force,
	};

func _process(delta: float) -> void:
	var forces = calculate_forces()
	var sum_forces = Vector2() if forces.is_empty() else forces.values().reduce(func(acc, val): return acc + val)

	velocity += (sum_forces * delta)

	# Maybe use a static body instead if collisions are becoming a hurdle
	move_and_slide()
