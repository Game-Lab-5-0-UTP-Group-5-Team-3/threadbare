extends Area2D

@export var key_id: String = "key_1"
signal picked(key_id: String)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("picked", key_id)
		queue_free()
