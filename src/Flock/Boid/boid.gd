extends CharacterBody2D
class_name Boid
var map_scene = preload("res://src/Map/Map.tscn")

var stamina_threshold := 10

var paintDropping := true

var max_speed_value := 600.0
var max_speed := Vector2(max_speed_value, max_speed_value)
var acceleration_factor := 200.0
@onready var thisAnimatedSprite = $AnimatedSprite2D


var formations = {
	Globals.FlyingFormation.SPACED: {
		"mouse_follow_force": 85.0,
		"cohesion_force": 60.0,
		"align_force": 80.0,
		"repulsion_force": 140.0,
		"animation": "acceleration",
	},
	Globals.FlyingFormation.TIGHTEN: {
		"mouse_follow_force": 80.0,
		"cohesion_force": 60.0,
		"align_force": 80.0,
		"repulsion_force": 65.0,
		"animation": "super_duper_acceleration",
	},
}


var flying_formation = Globals.FlyingFormation.SPACED

var mouse_follow_force = formations[flying_formation]["mouse_follow_force"]
var cohesion_force = formations[flying_formation]["cohesion_force"]
var align_force = formations[flying_formation]["align_force"]
var repulsion_force = formations[flying_formation]["repulsion_force"]

#Color attributes
#This qualify the color that the boid hold and the quantity remaining
var color = Color(0, 0, 0, 1);
var color_quantity = 0;

@onready var flock := $"../.." as Flock
@onready var repulsion_range := flock.repulsion_range

var is_hovering_painting = false

const BASE_COLOR: Color = Color.DIM_GRAY

func _ready() -> void:
	self.modulate = BASE_COLOR
	thisAnimatedSprite.play("acceleration")
	pass
	
	
func change_formation(formation: Globals.FlyingFormation):
	flying_formation = formation

	if formations.has(formation):
		mouse_follow_force = formations[formation]["mouse_follow_force"]
		cohesion_force = formations[formation]["cohesion_force"]
		align_force = formations[formation]["align_force"]
		repulsion_force = formations[formation]["repulsion_force"]
		thisAnimatedSprite.play(formations[formation]["animation"])
	else:
		assert(false, "Unknown flying formation")

func calculate_forces(target_position: Vector2) -> Array[Vector2]:
	# return {"x": Vector2.from_angle(randf_range(0, 2 * PI)) * randf_range(0, 100)}
	var center = flock.get_visible_neighbours_center(self)
	var align_vector = flock.get_alignment_vector(self)
	var repulsion_vector = flock.get_repulsion_vector(self)

	# Vector to get closer to the local center
	var cohesion_vector = global_position.direction_to(center);

	# Force to go toward mouse
	var mouse_vector = global_position.direction_to(target_position);
	var is_mouse_too_close_smooth = smoothstep(repulsion_range * .3 * .75, repulsion_range * .3 * 1.25, global_position.distance_to(target_position))
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
	if flock.active == false:
		return

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
	if not flock.player_has_control():
		return
	var area_parent = area.get_parent()
	if area_parent is not PaintPuddle and area_parent is not PaintVapor:
		#Cat
		return
	assert(area_parent is PaintPuddle or area_parent is PaintVapor)
	$GotPaintedSound.play_sound() # TODO: PLACEHOLDER
	color = area_parent.color
	assert(color != Color.WHITE)
	self.modulate = color
	color_quantity = area_parent.get_parent().get_parent().get_parent().color_quantity
	#When they get the painting, randomize a little the qqty
	#REMOVED : caimez - it was usless

func _input(event):
	if event is InputEventKey and event.keycode == KEY_SPACE:
		if event.is_pressed():
			change_formation(Globals.FlyingFormation.TIGHTEN)
		else:
			change_formation(Globals.FlyingFormation.SPACED)

	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			paintDropping = false
			thisAnimatedSprite.play("still")
		else:
			paintDropping = true
			thisAnimatedSprite.play(formations[flying_formation]["animation"])

@onready var previous_position = global_position
func _process(delta: float) -> void:
	#If they are compressed, lose stamina
	if flying_formation == Globals.FlyingFormation.TIGHTEN:
		flock.flockStamina -= 1 * delta
		# Not enough stamina -> go to spaced
		if flock.flockStamina < stamina_threshold:
			change_formation(Globals.FlyingFormation.SPACED)
	#Reload stamina when not pressed
	else:
		flock.flockStamina += 0.75 * delta if flock.flockStamina < 90 else 0

	if color_quantity < 0:
		color_quantity = 0
		self.modulate = BASE_COLOR

func shouldPaint() -> bool:
	return is_hovering_painting and paintDropping and color_quantity > 0 and flock.player_has_control()

func _on_painting_detector_area_entered(area: Area2D) -> void:
	is_hovering_painting = true

func _on_painting_detector_area_exited(area: Area2D) -> void:
	is_hovering_painting = false
