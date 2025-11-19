extends StaticBody2D

signal tried_to_open

@export var dialogue: DialogueResource
@export var dialogue_title: StringName = "start"

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_area: InteractArea = $InteractArea
@onready var talk_behavior: Node = $TalkBehavior
@onready var open_sound: AudioStreamPlayer2D = $OpenSound  # 🔊 AGREGADO

var opened: bool = false


func _ready() -> void:
	# Asegurar colisión activa
	if collision:
		collision.disabled = false

	# Configurar comportamiento de diálogo
	if talk_behavior:
		talk_behavior.dialogue = dialogue
		if talk_behavior.has_node("../InteractArea"):
			talk_behavior.interact_area = interact_area

	# Configurar área de interacción
	if interact_area:
		if interact_area.action == "":
			interact_area.action = "Talk"
		interact_area.interaction_started.connect(_on_interaction_started)


func _on_interaction_started(_player: Player, _from_right: bool) -> void:
	if opened:
		return

	var key_system := get_node("/root/StealthTemplateLevel/KeySystem")
	if key_system == null:
		return

	var keys_count: int = key_system.collected.size()

	if keys_count >= 2:
		# Tiene las dos llaves → abrir puerta
		if talk_behavior:
			talk_behavior.dialogue = null

		interact_area.disabled = true
		_open_door()
	else:
		# No tiene las llaves → aviso al HUD
		tried_to_open.emit()


# ------------------------------------------------------
# 🔓 Acción de abrir la puerta (fade-out + sonido real)
# ------------------------------------------------------
func _open_door() -> void:
	if opened:
		return
	opened = true

	print_debug("[DOOR] Ejecutando _open_door()")

	# 1️⃣ Desactivar colisión
	if collision:
		collision.set_deferred("disabled", true)

	# 2️⃣ Fade-out suave del sprite (0.35s)
	if sprite:
		var tween := create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.35)
		await tween.finished
		print_debug("[DOOR] Fade-out del sprite completado")

	# 3️⃣ Reproducir sonido si existe, y esperar a que termine
	if open_sound and open_sound.stream:
		open_sound.play()
		print_debug("[DOOR] 🔊 Reproduciendo sonido de puerta")

		# Espera real sin bloquear
		await open_sound.finished
		print_debug("[DOOR] Sonido terminado")
	else:
		print_debug("[DOOR] ⚠ No se encontró OpenSound. Procediendo sin audio")

	# 4️⃣ Eliminar puerta
	print_debug("[DOOR] Eliminando puerta con queue_free()")
	queue_free()
