extends Node2D
class_name Flock

@onready var boids_node = $Boids
@onready var painting = $"../Painting"
@onready var obstacleList = $"../Obstacles".get_children() as Array[Obstacle]

@export var flockStamina = 10000000
@export var flockSize = 60

var boid_scene = preload("res://src/Flock/Boid/Boid.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func spawn(flock_size: int):
	for _i in range(flock_size):
		add_boid()
	update_grids()

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
	boid_instance.global_position = global_position
	boid_instance.global_position += random_offset
	boid_instance.velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 100
	boids.append(boid_instance)

	# Update grid
	var cell = world_to_grid(boid_instance.global_position)
	if not grid.has(cell):
		grid[cell] = []
	grid[cell].append(boid_instance)

var view_range := 200.0
var cell_size: float = view_range
var grid: Dictionary = {}

var repulsion_range := 50.0
var small_cell_size: float = repulsion_range
var small_grid: Dictionary = {}

func update_grids() -> void:
	grid.clear()
	small_grid.clear()
	for boid in boids:
		var cell = world_to_grid(boid.global_position)
		if not grid.has(cell):
			grid[cell] = []
		grid[cell].append(boid)

		var small_cell = world_to_small_grid(boid.global_position)
		if not small_grid.has(small_cell):
			small_grid[small_cell] = []
		small_grid[small_cell].append(boid)


func world_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(floor(pos.x / cell_size), floor(pos.y / cell_size))

func world_to_small_grid(pos: Vector2) -> Vector2i:
	return Vector2i(floor(pos.x / small_cell_size), floor(pos.y / small_cell_size))

func get_neighbour_cells(cell: Vector2i) -> Array:
	return [
		cell,
		cell + Vector2i(1, 0),
		cell + Vector2i(-1, 0),
		cell + Vector2i(0, 1),
		cell + Vector2i(0, -1),
		cell + Vector2i(1, 1),
		cell + Vector2i(-1, -1),
		cell + Vector2i(1, -1),
		cell + Vector2i(-1, 1)
	]

var boids_center = Vector2()

var target = Vector2(0, 0)
var follow_mouse = false

func player_has_control():
	return follow_mouse

# When game stops
func stop_following_mouse(new_target: Vector2):
	follow_mouse = false
	target = new_target

# After intro
func start_following_mouse():
	follow_mouse = true

func _physics_process(_delta):
	boids_center = Vector2()
	for boid in boids:
		boids_center += boid.global_position
	boids_center /= boids.size()

	update_grids()

	if follow_mouse:
		target = get_global_mouse_position()

func get_visible_neighbours_center(boid: Boid) -> Vector2:
	if boids.size() == 1:
		return boid.global_position
	var new_center = (boids_center * boids.size() - boid.global_position) / (boids.size() - 1)
	return new_center

func get_repulsion_vector(boid: Boid) -> Vector2:
	var repulsion_vector = Vector2()
	for other_boid in get_close_neighbour_boids(boid):
		var distance = other_boid.global_position.distance_to(boid.global_position)
		repulsion_vector += (boid.global_position - other_boid.global_position) / (1. if distance == 0 else pow(distance, 2))
	
	
	for obstacle in obstacleList:
		var distance = Vector2(-300,-100).distance_to(boid.global_position)
		if distance < 100:
			repulsion_vector += 1*(boid.global_position - Vector2(-300,-100)) / (1. if distance == 0 else pow(distance, 1.5))
	return repulsion_vector

func get_alignment_vector(boid: Boid) -> Vector2:
	var alignment_vector = Vector2()
	var neighbours = get_neighbour_boids(boid)
	for other_boid in neighbours:
		alignment_vector += other_boid.velocity
	if neighbours.size() > 0:
		alignment_vector /= neighbours.size()
	return alignment_vector

func get_neighbour_boids(boid: Boid) -> Array[Boid]:
	var neighbours: Array[Boid] = []
	var boid_cell = world_to_grid(boid.global_position)
	var neighbour_cells = get_neighbour_cells(boid_cell)

	for cell in neighbour_cells:
		if grid.has(cell):
			for other_boid in grid[cell]:
				if other_boid != boid and other_boid.global_position.distance_to(boid.global_position) < view_range:
					neighbours.append(other_boid)

	return neighbours

func get_close_neighbour_boids(boid: Boid) -> Array[Boid]:
	var neighbours: Array[Boid] = []
	var boid_cell = world_to_small_grid(boid.global_position)
	var neighbour_cells = get_neighbour_cells(boid_cell)

	for cell in neighbour_cells:
		if small_grid.has(cell):
			for other_boid in small_grid[cell]:
				if other_boid != boid and other_boid.global_position.distance_to(boid.global_position) < repulsion_range:
					neighbours.append(other_boid)

	return neighbours
