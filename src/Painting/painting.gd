extends TextureRect

var invisible_texture = null
@onready var canvas: CanvasItem = Node2D.new()
@onready var map = $"../../../Map"

var _points: PackedVector2Array = []
var _colors: Array[Color] = []

var last_image: Image = Image.new()
var last_pattern_scale := 0.0
var last_center := Vector2(0, 0)

const CANVAS_SIZE = 100

@onready var line: Line2D = Line2D.new()

func _ready():
	var width_curve: Curve = Curve.new()
	line.width = 3
	line.width_curve = width_curve
	line.antialiased = true
	line.set_joint_mode(Line2D.LINE_JOINT_ROUND)
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.gradient = Gradient.new()
	add_child(line)

	# Debug
	for i in range(100):
		_points.append(Vector2(i, i))
		_colors.push_back(Color.RED)

func _draw():
	assert(_points.size() == _colors.size())

	var noise = FastNoiseLite.new()
	line.points = Array(_points)

	var width_curve = line.width_curve
	width_curve.clear_points()

	var gradient: Gradient = line.gradient
	gradient.colors = Array()

	var distance_max = 0.0
	for i in range(_points.size()):
		if i > 0:
			distance_max += _points[i].distance_to(_points[i - 1])
	var distance = 0.0
	for i in range(_points.size()):
		if i > 0:
			distance += _points[i].distance_to(_points[i - 1])
		var x = distance / distance_max
		var n = noise.get_noise_1d(distance * 20)
		var width = .7 + n * .5
		width_curve.add_point(Vector2(x, width), 0, 0)
		gradient.add_point(x, _colors[i].darkened((noise.get_noise_1d(distance * 200) + .8) * .25))

func _process(_delta):
	pass

const MINIMUM_LENGTH_TO_REVEAL = 15

func _gui_input(event):
	# if event is InputEventMouseButton:
	# 	if event.button_index == MOUSE_BUTTON_LEFT:
	# 		if map and !map.can_invoke():
	# 			return
	# 		elif event.pressed:
	# 			_mouse_down = true
	# 			emit_signal("start_drawing")
	# 			sketch_particles.emitting = true
	# 		else:
	# 			_mouse_down = false
	# 			emit_signal("end_drawing")
	# 			# Get distance to different seals
	# 			var distances = await get_distances_to_patterns(_points)
	# 			# If the drawing is not long enough, we do not give any hint to the player
	# 			if distances != null and _points.size() > MINIMUM_LENGTH_TO_REVEAL:
	# 				# Closest seal
	# 				var seal_distance = _get_closest_seal(distances)
	# 				$"../%SealsManager".give_hint(seal_distance["seal"], seal_distance["distance"])

	# 			# Generates a character following the distances to seals
	# 			var interpolated_chars = get_interpolated_characteristics(distances)
	# 			queue_redraw()
	# 			run_invocation_fx()
	# 			if interpolated_chars != null and map:
	# 				map.invoke(interpolated_chars, distances)
	# 			_points = []
	# 			_last_point = Vector2.INF
	# 			sketch_particles.emitting = false
	pass


func to_pack_vector2_array(array: Array[Vector2]) -> PackedVector2Array:
	return PackedVector2Array(array)

func draw_onto_canvas(points: PackedVector2Array):
	var colors = Array()
	colors.resize(points.size())
	colors.fill(Color.WHITE)
	RenderingServer.canvas_item_clear(canvas.get_canvas_item())
	RenderingServer.canvas_item_add_polyline(canvas.get_canvas_item(), to_pack_vector2_array(points), PackedColorArray(colors), CANVAS_SIZE * 0.05)
	RenderingServer.force_draw()
