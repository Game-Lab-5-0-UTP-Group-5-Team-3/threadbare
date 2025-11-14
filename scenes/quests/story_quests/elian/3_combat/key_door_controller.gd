extends Node

@export var key_item_path: NodePath
@export var door_path: NodePath

func _ready() -> void:
	var key_item := get_node_or_null(key_item_path)
	if key_item and key_item.has_signal("picked"):
		key_item.picked.connect(_on_key_picked)


func _on_key_picked(_id: String) -> void:
	var door := get_node_or_null(door_path)
	print(">>> Llave recogida. Abriendo puerta automáticamente.")

	if door and door.has_method("_open_door"):
		door._open_door()
