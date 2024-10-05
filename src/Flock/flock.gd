extends Node2D
class_name Flock

@onready var boids_node = $Boids
var boid_scene = preload("res://src/Flock/Boid/Boid.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_boid()
	add_boid()
	add_boid()
	add_boid()
	add_boid()
	add_boid()
	add_boid()
	add_boid()
	add_boid()
	add_boid()

func add_boid() -> void:
	var boid_instance = boid_scene.instantiate()
	boids_node.add_child(boid_instance)

	# TODO: handle that more properly
	var random_offset = Vector2(
		randf_range(10, 30),
		randf_range(10, 30),
	)
	boid_instance.global_position += random_offset;

func get_boids() -> Array[Boid]:
	var boids: Array[Boid] = []
	for node in boids_node.get_children():
		if node is Boid:
			boids.append(node as Boid)
	return boids

func get_neighbour_boids(boid: Boid) -> Array[Boid]:
	return get_boids().filter(
			func(other_boid: Boid): return (
			other_boid != boid and
			other_boid.global_position.distance_to(boid.global_position) < boid.view_range
		)
	)
