extends Node2D
class_name Flock

@onready var boids_node = $Boids
@onready var painting = $"../../Painting"

var boid_scene = preload("res://src/Flock/Boid/Boid.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for _i in range(30):
		add_boid()

var boids: Array[Boid] = []

func add_boid() -> void:
	var boid_instance = boid_scene.instantiate()
	boid_instance.connect("painting_drop", Callable(painting, "on_painting_drop"))
	boids_node.add_child(boid_instance)

	# TODO: handle that more properly
	var random_offset = Vector2(
		randf_range(0, 100),
		randf_range(0, 100),
	)
	boid_instance.global_position += random_offset;
	boid_instance.velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 100
	boids.append(boid_instance)

var boids_center = Vector2()
func _physics_process(delta):
	boids_center = Vector2()
	for boid in boids:
		boids_center += boid.global_position
	boids_center /= boids.size()

func get_boids() -> Array[Boid]:
	return boids
	# var boids: Array[Boid] = []
	# for node in boids_node.get_children():
	# 	if node is Boid:
	# 		boids.append(node as Boid)
	# return boids

func get_visible_neighbours_center(boid: Boid) -> Vector2:
	var neighbours = get_neighbour_boids(boid)
	var center = Vector2.ZERO
	var n = 0
	for neighbour in neighbours:
		if neighbour != boid and neighbour.global_position.distance_to(boid.global_position) > boid.repulsion_range:
			center += neighbour.global_position
			n += 1
	if n > 0:
		center /= n
	return center
	# var new_center = (boids_center * boids.size() - boid.global_position) / (boids.size() - 1)
	# return new_center

func get_repulsion_vector(boid: Boid) -> Vector2:
	var repulsion_vector = Vector2()
	for other_boid in get_neighbour_boids(boid):
		var distance = other_boid.global_position.distance_to(boid.global_position)
		if distance < boid.repulsion_range:
			repulsion_vector += (boid.global_position - other_boid.global_position) / pow(distance, 2)
	return repulsion_vector

func get_alignment_vector(boid: Boid) -> Vector2:
	var alignment_vector = Vector2()
	for other_boid in get_neighbour_boids(boid):
		alignment_vector += other_boid.velocity
	if get_neighbour_boids(boid).size() > 0:
		alignment_vector /= get_neighbour_boids(boid).size()
	return alignment_vector

func get_neighbour_boids(boid: Boid) -> Array[Boid]:
	return get_boids().filter(
			func(other_boid: Boid): return (
			other_boid != boid and
			other_boid.global_position.distance_to(boid.global_position) < boid.view_range
		)
	)
