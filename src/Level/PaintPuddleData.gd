extends Resource
class_name PaintPuddleData

@export var position: Vector2
@export var color: Color = Color(1., 0., 0., 1.)
@export var color_quantity: int = 100
@export var puddle_size: int = 2 
@export var container_type: PaintPuddle.ContainerType = PaintPuddle.ContainerType.TUBE
