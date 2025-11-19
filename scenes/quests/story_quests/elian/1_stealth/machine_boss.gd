extends Node2D

@export var machine_id: int = 4

@onready var interact_area: InteractArea = $InteractArea
@onready var talk_behavior: TalkBehavior = $TalkBehavior
@onready var stealth_logic := get_node_or_null("/root/StealthTemplateLevel/StealthGameLogic")
@onready var player := get_tree().get_first_node_in_group("player")
@onready var boss := get_node_or_null("/root/StealthTemplateLevel/Interactables/Boss")
@onready var collectible := get_node_or_null("/root/StealthTemplateLevel/CollectibleItem") # nuevo
@onready var dm := DialogueManager

@export var dialogue_machine4: DialogueResource
@export var dialogue_machine5: DialogueResource
@export var dialogue_machine6: DialogueResource
@export var dialogue_idle: DialogueResource

var _showing_idle := false
var _connected := false
var _consumed_action := false
static var _machines_disabled := false  # Todas las máquinas comparten este estado


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# Ocultar collectible al inicio
	if collectible:
		collectible.visible = false
		var shape := collectible.get_node_or_null("CollisionShape2D")
		if shape:
			shape.disabled = true
		var area := collectible.get_node_or_null("InteractArea")
		if area:
			area.monitoring = false
			area.monitorable = false

	talk_behavior.before_dialogue = func() -> void:
		if _machines_disabled:
			talk_behavior.dialogue = dialogue_idle
			_showing_idle = true
			return

		match machine_id:
			4: talk_behavior.dialogue = dialogue_machine4
			5: talk_behavior.dialogue = dialogue_machine5
			6: talk_behavior.dialogue = dialogue_machine6
			_: talk_behavior.dialogue = dialogue_idle

		if stealth_logic and stealth_logic.has_method("set_process"):
			stealth_logic.set_process(false)

	if not _connected and dm:
		dm.dialogue_ended.connect(_on_dialogue_finished)
		_connected = true


func _on_dialogue_finished(_dialogue: DialogueResource) -> void:
	if _consumed_action:
		return
	if not talk_behavior or _dialogue != talk_behavior.dialogue:
		if stealth_logic:
			stealth_logic.set_process(true)
		return

	_consumed_action = true
	if stealth_logic:
		stealth_logic.set_process(true)

	if _machines_disabled:
		return

	match machine_id:
		4, 5:
			if is_instance_valid(player):
				player.mode = player.Mode.DEFEATED
				if "defeated" in player.player_sprite.sprite_frames.get_animation_names():
					player.player_sprite.play("defeated")
			await get_tree().create_timer(1.2).timeout
			_restart_scene()

		6:
			# SOPHIA – animación de muerte completa + fade out + sonido
			if is_instance_valid(boss):
				var sprite := boss.get_node_or_null("Sprite2D")
				var death_sound := boss.get_node_or_null("DeathSound")
				print_debug("[SOPHIA] sprite:", sprite)

				if sprite and sprite.sprite_frames.has_animation("dead"):
					sprite.play("dead")

					# 🔊 Reproducir sonido de muerte
					if death_sound:
						death_sound.play()

					# Calcular duración REAL de la animación
					var frames: int = sprite.sprite_frames.get_frame_count("dead")
					var fps: float = sprite.sprite_frames.get_animation_speed("dead")
					var duration: float = float(frames) / fps

					print_debug("[SOPHIA] Duración animación:", duration)
					await get_tree().create_timer(duration).timeout

					# 🎨 FADE OUT suave (0.45s)
					var tween := create_tween()
					tween.tween_property(sprite, "modulate:a", 0.0, 0.45)
					await tween.finished

				else:
					print_debug("[SOPHIA] ⚠ No encontró animación 'dead'")

				# Eliminar boss después del fade out
				boss.queue_free()
				print_debug("[MACHINE]", machine_id, "→ boss eliminado correctamente")

			# Activar collectible
			if is_instance_valid(collectible):
				collectible.visible = true
				var shape := collectible.get_node_or_null("CollisionShape2D")
				if shape:
					shape.disabled = false
				var area := collectible.get_node_or_null("InteractArea")
				if area:
					area.monitoring = true
					area.monitorable = true

				print_debug("[MACHINE]", machine_id, "→ collectible activado correctamente")

			_disable_all_machines()


func _disable_all_machines() -> void:
	print_debug("[MACHINE] → Todas las máquinas ahora son idle y obsoletas.")
	_machines_disabled = true


func _restart_scene() -> void:
	if stealth_logic and stealth_logic.has_method("reload_scene_safe"):
		call_deferred("_reload_via_logic")
	else:
		call_deferred("_reload_fallback")


func _reload_via_logic() -> void:
	stealth_logic.reload_scene_safe()


func _reload_fallback() -> void:
	get_tree().reload_current_scene()
