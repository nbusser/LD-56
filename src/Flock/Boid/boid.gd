extends CharacterBody2D
class_name Boid
var map_scene = preload("res://src/Map/Map.tscn")
signal painting_drop(Vector2, Color, int)

var max_speed_value := 300.0
var max_speed := Vector2(max_speed_value, max_speed_value)
var acceleration_factor := 100.0

const default_repulsion_force := 140.0

# Force factors
# var mouse_follow_factor := 1.0
var mouse_follow_force := 50.0
var cohesion_force := 100.0
var align_force := 80.0
var repulsion_force := default_repulsion_force


#Color attributes
#This qualify the color that the boid hold and the quantity remaining
#This could be usless but it is here if needed
var color = Color(0, 0, 0, 1);
var color_quantity = 0;

@onready var flock := $"../.." as Flock
@onready var repulsion_range := flock.repulsion_range


func calculate_forces(target_position: Vector2) -> Array[Vector2]:
	# return {"x": Vector2.from_angle(randf_range(0, 2 * PI)) * randf_range(0, 100)}

	var center = flock.get_visible_neighbours_center(self)
	var align_vector = flock.get_alignment_vector(self)
	var repulsion_vector = flock.get_repulsion_vector(self)

	# Vector to get closer to the local center
	var cohesion_vector = global_position.direction_to(center);

	# Force to go toward mouse
	var mouse_vector = global_position.direction_to(target_position);
	var is_mouse_too_close_smooth = smoothstep(repulsion_range * .75, repulsion_range * 1.25, global_position.distance_to(target_position))
	var mouse_force = mouse_vector.normalized() * mouse_follow_force * is_mouse_too_close_smooth

	# return {
	# # "cohesion": cohesion_vector.normalized() * cohesion_force * (1 if n_attracted_to > 0 else 0),
	# # "repulsion": repulsion_vector.normalized() * repulsion_force * (1 if n_repulsion > 0 else 0),
	# "cohesion": cohesion_vector.normalized() * cohesion_force,
	# "repulsion": repulsion_vector.normalized() * repulsion_force,
	# 	"align": align_vector.normalized() * align_force,
	# 	"mouse": mouse_force,
	# };
	return [
		cohesion_vector.normalized() * cohesion_force,
		repulsion_vector.normalized() * repulsion_force,
		align_vector.normalized() * align_force,
		mouse_force,
	]

func _physics_process(delta) -> void:
	# Force
	var forces = calculate_forces(flock.target)
	# var sum_forces = Vector2() if forces.is_empty() else forces.values().reduce(func(acc, val): return acc + val)
	var sum_forces = Vector2.ZERO if forces.is_empty() else forces.reduce(func(acc, val): return acc + val)

	var direction_alignment = pow((1 - clamp(velocity.normalized().dot(sum_forces.normalized()), -1., 1.)) / 2, .5) # 1 if opposite, 0 if aligned
	var speed_factor = clamp(1 - velocity.length() / max_speed_value, 0, 1)

	var force = sum_forces * acceleration_factor * (speed_factor + (1 - speed_factor) * direction_alignment)
	# var force = sum_forces * acceleration_factor * delta

	# apply_central_force(force)
	self.velocity += force * delta

	# Limit speed
	var current_speed = velocity.length()
	if current_speed > max_speed_value:
		velocity = velocity.normalized() * max_speed_value
	# Rotate to match the velocity
	if velocity.length() > 0:
		rotation = velocity.angle()

	# Move
	move_and_slide()

# Enter paint puddle
func _on_paint_puddle_detector_area_entered(area: Area2D) -> void:
	var area_parent = area.get_parent()
	assert(area_parent is PaintPuddle)
	color = area_parent.color
	color_quantity = area_parent.color_quantity

func _input(event):
	# TODO: discuss about this idea
	if event is InputEventMouseButton:
		if flock.flockStamina < 10 :
			repulsion_force = default_repulsion_force
			return	 
		if event.button_index == 1 and event.is_pressed():
			repulsion_force = default_repulsion_force * 0.4
		elif event.button_index == 1 and not event.is_pressed():
			repulsion_force = default_repulsion_force

func _process(delta: float) -> void:
	#Drop paint
	if color_quantity > 0:
		if is_hovering_painting:
			emit_signal("painting_drop", global_position, velocity, color, color_quantity, delta)
			color_quantity -= 20 * delta
	#If they are compressed
	if repulsion_force == default_repulsion_force *0.4:	
		flock.flockStamina -= 1*delta
	#Reload stamina when not pressed
	else:
		flock.flockStamina += 1*delta if flock.flockStamina < 90 else 0
	if flock.flockStamina < 10 :
		repulsion_force = default_repulsion_force
	


var is_hovering_painting = false

func _on_painting_detector_area_entered(area: Area2D) -> void:
	is_hovering_painting = true


func _on_painting_detector_area_exited(area: Area2D) -> void:
	is_hovering_painting = false
