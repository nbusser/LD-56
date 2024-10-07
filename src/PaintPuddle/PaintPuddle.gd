@tool

extends Node2D
class_name PaintPuddle

@onready var container_parent: Node2D = $ContainerParent

const Tube = preload("res://src/PaintPuddle/Containers/Tube.tscn")
const TubeTilted = preload("res://src/PaintPuddle/Containers/TubeTilted.tscn")
const Flask = preload("res://src/PaintPuddle/Containers/Flask.tscn")
const Flask2 = preload("res://src/PaintPuddle/Containers/Flask2.tscn")
const Cauldron = preload("res://src/PaintPuddle/Containers/Cauldron.tscn")

enum ContainerType {
	TUBE,
	TUBE_TILTED,
	FLASK,
	FLASK_2,
	CAULDRON,
}

var container: Node2D

@export_color_no_alpha var color : Color = Color.WHITE:
	get():
		return color
	set(value):
		self._on_update_color(value)
		color = value

@export var container_type: ContainerType = ContainerType.TUBE:
	get():
		return container_type
	set(value):
		self._on_update_container_type(value)
		container_type = value

var color_quantity = 100

func init(pos: Vector2, size: int, color: Color, quantity: int, container_type: ContainerType) -> void:
	self.scale *= size
	self.position = pos
	self.color = color
	self.modulate = color
	#Modulate the quantity depending on the quantity and the scaling
	#TODO CHANGE THE 3 DEPENDING ON THE SCALING OF THE ITEM
	#This will result in less paint from the start of the bidule
	self.color_quantity = quantity * size/5
	self.container_type = container_type

func _ready() -> void:
	call_deferred("_on_update_container_type", self.container_type)

func _on_update_color(value: Color):
	if container:
			container.color = value

func _on_update_container_type(value: ContainerType):
	if not container_parent:
		return
	
	container = null
	for child in container_parent.get_children():
		child.queue_free()
	match value:
		ContainerType.TUBE:
			container = Tube.instantiate()
		ContainerType.TUBE_TILTED:
			container = TubeTilted.instantiate()
		ContainerType.FLASK:
			container = Flask.instantiate()
		ContainerType.FLASK_2:
			container = Flask2.instantiate()
		ContainerType.CAULDRON:
			container = Cauldron.instantiate()
	if container:
		container_parent.add_child(container)
		_on_update_color(self.color)
