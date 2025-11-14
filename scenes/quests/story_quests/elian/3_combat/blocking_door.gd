extends Node2D

@onready var sprite := $Sprite2D
@onready var collider := $Collider
@onready var collision_shape := $Collider/CollisionShape2D
@onready var open_sound := $OpenSound

var opened := false


func open_door():
	if opened:
		return
	opened = true

	# --- Sonido de apertura ---
	if open_sound:
		open_sound.play()

	# --- Desactivar colisión para que el BlackHole pueda pasar ---
	if collision_shape:
		collision_shape.disabled = true

	# --- Fade-out del sprite ---
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.4)  # más rápido y más limpio

	await tween.finished

	# --- Ocultar realmente ---
	sprite.visible = false
