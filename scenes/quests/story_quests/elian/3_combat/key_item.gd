extends Node2D

signal picked(key_id: String)

@export var key_id := "boss_key"

func _ready() -> void:
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print(">>> Key picked:", key_id)
		picked.emit(key_id)
		queue_free()
