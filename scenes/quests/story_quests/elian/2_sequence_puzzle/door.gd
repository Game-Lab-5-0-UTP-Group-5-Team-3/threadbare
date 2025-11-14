extends Node2D

signal tried_to_open

@onready var interact_area: Area2D = $InteractArea
@onready var collision := $CollisionShape2D
@onready var open_sound := $OpenSound   # ← nodo de sonido

func _ready():
	if interact_area:
		interact_area.interaction_started.connect(_on_interaction_started)


func _on_interaction_started(_player, _from_right):
	tried_to_open.emit()  # avisa al KeySystem que intentaron abrir


func _open_door():

	print("DEBUG | open_sound:", open_sound)

	# 🔊 reproducir sonido si existe
	if open_sound:
		open_sound.play()
		print("DEBUG | Sonido reproducido. Esperando a que termine...")

	# ❌ desactivar colisión
	if collision:
		collision.disabled = true

	print("🚪 Puerta abierta")

	# 🔊 Si existe sonido, esperar a que termine ANTES de borrar la puerta
	if open_sound and open_sound.stream:
		await open_sound.finished
	else:
		# fallback mínimo en caso no tenga stream
		await get_tree().create_timer(0.2).timeout

	# 🗑 eliminar puerta después de abrir
	queue_free()
