extends Node2D

@export var machine_id: int = 1

@onready var interact_area: InteractArea = $InteractArea
@onready var talk_behavior: TalkBehavior = $TalkBehavior
@onready var key1 := $"../../Keys/Key1"
@onready var key_system := get_node_or_null("/root/StealthTemplateLevel/KeySystem")
@onready var stealth_logic := get_node_or_null("/root/StealthTemplateLevel/StealthGameLogic")
@onready var player := get_tree().get_first_node_in_group("player")
@onready var dm := DialogueManager

@export var dialogue_machine1: DialogueResource
@export var dialogue_machine2: DialogueResource
@export var dialogue_machine3: DialogueResource
@export var dialogue_idle: DialogueResource

var _showing_idle := false
var _consumed_action := false
var _connected := false


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	print_debug("[MACHINE]", machine_id, "ready()")

	talk_behavior.before_dialogue = func() -> void:
		_showing_idle = _should_be_idle()

		if _showing_idle:
			talk_behavior.dialogue = dialogue_idle
		else:
			match machine_id:
				1: talk_behavior.dialogue = dialogue_machine1
				2: talk_behavior.dialogue = dialogue_machine2
				3: talk_behavior.dialogue = dialogue_machine3

		# 🚫 Pausar lógica stealth durante diálogo
		if stealth_logic and stealth_logic.has_method("set_process"):
			stealth_logic.set_process(false)

	if not _connected and dm:
		dm.dialogue_ended.connect(_on_dialogue_finished)
		_connected = true


func _should_be_idle() -> bool:
	return key_system and "key_1" in key_system.collected


func _on_dialogue_finished(_dialogue: DialogueResource) -> void:
	if _consumed_action:
		return
	if not talk_behavior or _dialogue != talk_behavior.dialogue:
		if stealth_logic:
			stealth_logic.set_process(true)
		return

	print_debug("[MACHINE]", machine_id, "→ diálogo finalizado correctamente")
	_consumed_action = true

	if stealth_logic:
		stealth_logic.set_process(true)

	if _showing_idle:
		return

	match machine_id:
		1, 2:
			if is_instance_valid(player):
				player.mode = player.Mode.DEFEATED
				var anim_names: PackedStringArray = player.player_sprite.sprite_frames.get_animation_names()

				if "defeated" in anim_names:
					player.player_sprite.play("defeated")
					print_debug("[MACHINE]", machine_id, "→ animación 'defeated' reproducida")

			await get_tree().create_timer(1.2).timeout
			_restart_scene()

		3:
			if is_instance_valid(key1):
				key1.visible = true
				var shape := key1.get_node_or_null("CollisionShape2D")
				if shape:
					shape.disabled = false
				print_debug("[MACHINE]", machine_id, "→ llave revelada correctamente")

				# ✅ Actualizar sistema de llaves (señalando que ya fue obtenida)
				if key_system and not ("key_1" in key_system.collected):
					key_system.collected["key_1"] = true

				# ✅ Cambiar permanentemente el diálogo a idle
				_showing_idle = true
				talk_behavior.dialogue = dialogue_idle
				_consumed_action = false  # permite futuras interacciones pero ya en idle
				print_debug("[MACHINE]", machine_id, "→ modo idle activado tras entregar llave")


func _restart_scene() -> void:
	print_debug("[MACHINE]", machine_id, "→ reiniciando escena inmediatamente (seguro)")
	if stealth_logic and stealth_logic.has_method("reload_scene_safe"):
		call_deferred("_reload_via_logic")
	else:
		call_deferred("_reload_fallback")


func _reload_via_logic() -> void:
	stealth_logic.reload_scene_safe()


func _reload_fallback() -> void:
	get_tree().reload_current_scene()
