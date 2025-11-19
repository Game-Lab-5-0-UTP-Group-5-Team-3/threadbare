extends StaticBody2D

# 🔔 Señal para avisar al KeySystem cuando el jugador intenta abrir la puerta sin las 2 llaves
signal tried_to_open

@export var dialogue: DialogueResource
@export var dialogue_title: StringName = "start"

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_area: InteractArea = $InteractArea
@onready var talk_behavior: Node = $TalkBehavior

var opened: bool = false

func _ready() -> void:
	# Asegura que la colisión esté activa al iniciar
	if collision:
		collision.disabled = false

	# Configura el comportamiento de diálogo (como el checkpoint)
	if talk_behavior:
		talk_behavior.dialogue = dialogue
		if talk_behavior.has_node("../InteractArea"):
			talk_behavior.interact_area = interact_area

	# Configura el área de interacción
	if interact_area:
		if interact_area.action == "":
			interact_area.action = "Talk"
		interact_area.interaction_started.connect(_on_interaction_started)


# 🔹 Cuando el jugador interactúa con la puerta
func _on_interaction_started(_player: Player, _from_right: bool) -> void:
	if opened:
		return

	var key_system := get_node("/root/StealthTemplateLevel/KeySystem")
	if key_system == null:
		return

	var keys_count: int = key_system.collected.size()

	if keys_count >= 2:
		# ✅ Tiene las dos llaves → abrir puerta
		if talk_behavior:
			talk_behavior.dialogue = null
		interact_area.disabled = true
		_open_door()
	else:
		# 🚫 No tiene las llaves → avisar al sistema (HUD mostrará el mensaje)
		tried_to_open.emit()


# 🔹 Acción para abrir la puerta
func _open_door() -> void:
	if opened:
		return
	opened = true

	if collision:
		collision.set_deferred("disabled", true)
	if sprite:
		sprite.visible = false

	# Eliminar la puerta de forma segura
	call_deferred("queue_free")
