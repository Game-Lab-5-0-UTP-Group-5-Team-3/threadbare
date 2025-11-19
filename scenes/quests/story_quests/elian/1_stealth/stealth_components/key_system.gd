extends Node

@onready var key1 := $"../Interactables/Keys/Key1"
@onready var key2 := $"../Interactables/Keys/Key2"
@onready var door := $"../Interactables/Door"
@onready var hud := $"../StoryHUDs/KeysHUD"

@onready var player := $"../Player"
@onready var camera := $"../Player/Camera2D"

@export var door_focus_offset: Vector2 = Vector2.ZERO

var collected := {}
var returning := false


func _ready():
	if key1:
		key1.picked.connect(_on_key_picked)
	if key2:
		key2.picked.connect(_on_key_picked)

	if door:
		door.tried_to_open.connect(_on_door_tried)

	if hud:
		hud.update_count(0, 2)


func _on_key_picked(key_id: String):
	collected[key_id] = true
	hud.update_count(collected.size(), 2)

	if collected.size() >= 2:
		_start_door_cutscene()


func _on_door_tried():
	pass


# ---------------------------------------------------------------
# 🎥 CUTSCENE COMPLETA + sonido sincronizado (con debug)
# ---------------------------------------------------------------
func _start_door_cutscene():
	if not player or not camera or not door:
		door._open_door()
		return

	if returning:
		return
	returning = true

	await get_tree().process_frame

	# 1. Congelar jugador
	var was_proc := player.is_processing()
	var was_phys := player.is_physics_processing()

	player.set_process(false)
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	player.input_vector = Vector2.ZERO

	# 2. Posición inicial cámara
	var cam_start: Vector2 = camera.global_position

	# 3. Posición objetivo (puerta)
	var door_sprite := door.get_node_or_null("Sprite2D") as Node2D
	var target: Vector2 = (door_sprite.global_position if door_sprite else door.global_position)
	target += door_focus_offset

	# 4. Desactivar smoothing
	camera.position_smoothing_enabled = false

	# 5. Paneo a la puerta
	var tween := create_tween()
	tween.tween_property(camera, "global_position", target, 0.9)
	await tween.finished

	# ---------------------------------------------------
	# 🔊 5.1 REPRODUCIR SONIDO EXACTAMENTE AL LLEGAR
	# ---------------------------------------------------
	var door_sfx := door.get_node_or_null("OpenSound")

	print_debug("[CUTSCENE] Intentando reproducir sonido de puerta:", door_sfx)

	if door_sfx and door_sfx.stream:
		door_sfx.play()
		print_debug("[CUTSCENE] 🔊 Sonido puerta → PLAY() ejecutado correctamente")
	else:
		print_debug("[CUTSCENE] ⚠ NO se pudo reproducir sonido (nodo o stream nulo)")


	# 6. Abrir puerta (SIN sonido)
	door._open_door()

	# 7. Esperar para que se vea la desaparición
	await get_tree().create_timer(0.6).timeout

	# 8. Paneo de vuelta
	var tween_back := create_tween()
	tween_back.tween_property(camera, "global_position", cam_start, 0.9)
	await tween_back.finished

	# 9. Restaurar jugador y smoothing
	camera.position_smoothing_enabled = true

	if was_proc:
		player.set_process(true)
	if was_phys:
		player.set_physics_process(true)

	returning = false
