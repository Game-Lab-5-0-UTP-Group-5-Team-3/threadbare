extends Node

@export var boss_path: NodePath
@export var door_path: NodePath

func _ready() -> void:
	var boss := get_node_or_null(boss_path)
	if boss and boss.has_signal("defeated"):
		boss.connect("defeated", Callable(self, "_on_boss_defeated"))


func _on_boss_defeated() -> void:
	print(">>> Boss derrotado, abriendo BossDoor.")
	var door := get_node_or_null(door_path)
	if door and door.has_method("_open_door"):
		door._open_door()
