extends RigidBody2D
class_name Boid

signal painting_drop(Vector2, Color)

var max_speed_value := 200.0
var max_speed := Vector2(max_speed_value, max_speed_value)
var acceleration_factor := 200.0

# Force factors
var mouse_follow_force := 100.0
var cohesion_force := 25.0
var align_force := 30.0
var repulsion_force := 50.0

# Ranges
var view_range := 50.0
var repulsion_range := 30.0

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

	var n_center = 0
	var n_repulsion = 0

	for neighbour in neighbours:
		var distance_to_neighbour = global_position.distance_to(neighbour.global_position)
		if distance_to_neighbour < repulsion_range:
			repulsion_vector -= (neighbour.global_position - global_position).normalized()
			n_repulsion += 1
		else:
			center += neighbour.global_position
			n_center += 1
		
		align_vector += neighbour.linear_velocity

	if n_center > 0:
		center /= n_center;
	
	if n_repulsion > 0:
		align_vector /= n_repulsion;

	# Vector to get closer to the local center
	var cohesion_vector = Vector2() if n_center == 0 else global_position.direction_to(center);

	# Force to go toward mouse
	var mouse_vector = global_position.direction_to(get_global_mouse_position());

	return {
		"cohesion": cohesion_vector.normalized() * cohesion_force,
		"repulsion": repulsion_vector.normalized() * repulsion_force,
		"align": align_vector.normalized() * align_force,
		"mouse": mouse_vector.normalized() * mouse_follow_force,
	};

func _physics_process(delta: float) -> void:
	# Force
	var forces = calculate_forces()
	var sum_forces = Vector2() if forces.is_empty() else forces.values().reduce(func(acc, val): return acc + val)

	var force = sum_forces * acceleration_factor * delta
	apply_central_force(force);

	if is_hovering_painting:
		emit_signal("painting_drop", global_position, Color.RED)


var is_hovering_painting = false

func _on_painting_detector_area_entered(area: Area2D) -> void:
	is_hovering_painting = true


func _on_painting_detector_area_exited(area: Area2D) -> void:
	is_hovering_painting = false
