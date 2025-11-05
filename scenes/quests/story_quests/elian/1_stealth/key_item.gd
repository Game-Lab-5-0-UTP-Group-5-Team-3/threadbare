extends Area2D

signal key_collected

var _taken := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _taken:
		return
	if body.is_in_group("player"):
		_taken = true
		emit_signal("key_collected")  # avisa al StealthGameLogic
		queue_free()  # la llave desaparece
