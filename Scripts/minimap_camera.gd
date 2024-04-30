extends Camera3D

#export(NodePath) var target_path: NodePath
@export var target_path: NodePath
var target: Node3D
var offset: Vector3

func _ready():
	target = get_node(target_path)
	if target == null:
		return
	offset = Vector3(0, global_transform.origin.y - target.global_transform.origin.y, 0)

func _process(_delta):
	if target == null:
		return
	global_transform.origin = Vector3(target.global_transform.origin.x + offset.x, global_transform.origin.y, target.global_transform.origin.z + offset.z)

