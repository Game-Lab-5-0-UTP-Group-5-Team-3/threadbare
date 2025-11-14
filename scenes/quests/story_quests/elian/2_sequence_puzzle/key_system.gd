extends Node

# --- RUTAS CORRECTAS SEGÚN TU ÁRBOL ---
@onready var key1 := $"../Interactables/Keys/Key1"
@onready var key2 := $"../Interactables/Keys/Key2"
@onready var door := $"../Interactables/Door"
@onready var hud := $"../StoryHUDs/KeysHUD"


@onready var player: Player   = $"../OnTheGround/Player"
@onready var camera: Camera2D = $"../OnTheGround/Player/Camera2D"

# Pequeño ajuste para centrar mejor la puerta en pantalla (lo puedes mover en el Inspector)
@export var door_focus_offset: Vector2 = Vector2.ZERO

var collected: Dictionary = {}
var returning: bool = false


func _ready() -> void:
	# Conectar llaves
	if key1:
		key1.picked.connect(_on_key_picked)
	if key2:
		key2.picked.connect(_on_key_picked)

	# Conectar puerta
	if door:
		door.tried_to_open.connect(_on_door_tried)

	# HUD
	if hud:
		hud.update_count(0, 2)


func _on_key_picked(key_id: String) -> void:
	collected[key_id] = true

	if hud:
		hud.update_count(collected.size(), 2)

	# Cuando tenga ambas llaves, lanzamos la “cutscene” de la puerta
	if collected.size() >= 2:
		_start_door_cutscene()


func _on_door_tried() -> void:
	pass


func _start_door_cutscene() -> void:
	# Si falta algo importante, abrimos la puerta sin animación
	if not player or not camera or not door:
		if door:
			door._open_door()
		return

	if returning:
		return
	returning = true

	await get_tree().process_frame

	# 1) Congelar al jugador (no se mueve ni aunque toques el teclado)
	var was_processing := player.is_processing()
	var was_physics_processing := player.is_physics_processing()

	player.set_process(false)
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	player.input_vector = Vector2.ZERO
	player.mode = player.Mode.COZY

	# 2) Guardar la posición inicial de la cámara (para volver luego)
	var cam_start_pos: Vector2 = camera.global_position

	# 3) Calcular posición objetivo sobre la puerta
	var door_sprite := door.get_node_or_null("Sprite2D") as Node2D
	var door_pos: Vector2 = (door_sprite.global_position if door_sprite else door.global_position)
	door_pos += door_focus_offset

	# 4) Desactivar smoothing para que el tween mande
	camera.position_smoothing_enabled = false

	# 5) Paneo suave hacia la puerta
	var tween := create_tween()
	tween.tween_property(camera, "global_position", door_pos, 0.9)
	await tween.finished

	# 6) Abrir puerta (sonido + desaparecer)
	door._open_door()

	# 7) Pequeña pausa para que se vea la desaparición
	await get_tree().create_timer(0.6).timeout

	# 8) Volver con paneo al punto inicial de la cámara
	var tween_back := create_tween()
	tween_back.tween_property(camera, "global_position", cam_start_pos, 0.9)
	await tween_back.finished

	# 9) Restaurar cámara y jugador
	camera.position_smoothing_enabled = true

	if was_processing:
		player.set_process(true)
	if was_physics_processing:
		player.set_physics_process(true)

	player.mode = player.Mode.COZY
	returning = false
