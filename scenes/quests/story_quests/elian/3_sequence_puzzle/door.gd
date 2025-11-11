extends Node2D

signal tried_to_open

@onready var interact_area: Area2D = $InteractArea
@onready var collision := $CollisionShape2D

func _ready():
	if interact_area:
		interact_area.interaction_started.connect(_on_interaction_started)

func _on_interaction_started(_player, _from_right):
	tried_to_open.emit()  # avisa al KeySystem que intentaron abrir

func _open_door():
	# Desactiva colisión y muestra efecto de apertura
	if collision:
		collision.disabled = true
	print("🚪 Puerta abierta")
	queue_free()  # opcional: eliminar la puerta al abrir
