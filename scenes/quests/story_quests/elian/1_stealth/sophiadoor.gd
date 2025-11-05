#elian puerta
extends Node2D

@export var total_keys_required := 2
@export var revealed: bool = true:
	set(new_value):
		revealed = new_value
		_update_based_on_revealed()

@export_category("Dialogue")
@export var locked_dialogue: DialogueResource
@export var dialogue_title: StringName = "start"

@onready var interact_area: InteractArea = $InteractArea
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var physical_collider: CollisionShape2D = $CollisionShape2D

var is_open := false

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# Configurar texto contextual
	if interact_area:
		interact_area.action = "¿Qué es esto?"

	# Conectar interacción
	interact_area.interaction_started.connect(_on_interacted)

	# Ajustar visibilidad inicial
	_update_based_on_revealed()

func _on_interacted(player: Player, _from_right: bool) -> void:
	if is_open:
		return

	var logic := get_tree().get_first_node_in_group("stealth_logic")
	if not logic:
		push_warning("⚠️ No se encontró el grupo 'stealth_logic'.")
		return

	if logic.keys_collected < total_keys_required:
		if locked_dialogue:
			DialogueManager.show_dialogue_balloon(locked_dialogue, dialogue_title, [self, player])
			await DialogueManager.dialogue_ended
		else:
			print("SophIA: Aún no tienes las dos llaves.")
	else:
		open_door()

	interact_area.end_interaction()

func open_door() -> void:
	is_open = true
	print("✅ Puerta de SophIA abierta.")
	physical_collider.disabled = true
	queue_free()

func _update_based_on_revealed() -> void:
	if interact_area:
		interact_area.disabled = not revealed
	if sprite_2d:
		sprite_2d.visible = revealed
	if physical_collider:
		physical_collider.disabled = not revealed
## fin elian puerta
