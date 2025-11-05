# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
# Machine1 – versión segura (usa balloon global; sin lógica de llave)

extends Node2D

@onready var interact_area: InteractArea = $InteractArea
@onready var sprite: Sprite2D = $Sprite2D

@export var dialogue_machine: DialogueResource
@export var dialogue_title: StringName = "start"

var used := false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if interact_area:
		interact_area.interaction_started.connect(_on_interacted)
		interact_area.action = "Examinar"

func _on_interacted(player: Player, _from_right: bool) -> void:
	if used:
		print("💻 No hay nada pendiente que hacer aquí. Sistema en reposo.")
		return

	if not dialogue_machine:
		print("⚠️ Falta asignar 'dialogue_machine' en Machine1.")
		return

	var dm := DialogueManager
	dm.show_dialogue_balloon(dialogue_machine, dialogue_title, [self, player])

	# Conectar a eventos del diálogo si existen
	if dm.has_signal("dialogue_event") and not dm.is_connected("dialogue_event", Callable(self, "_on_dialogue_event")):
		dm.connect("dialogue_event", Callable(self, "_on_dialogue_event"))

	await dm.dialogue_ended

	if dm.has_signal("dialogue_event") and dm.is_connected("dialogue_event", Callable(self, "_on_dialogue_event")):
		dm.disconnect("dialogue_event", Callable(self, "_on_dialogue_event"))

func _on_dialogue_event(command: String, _args: Array) -> void:
	match command:
		"reiniciar", "muerte":
			_trigger_restart()
		_: # Cualquier otro evento será ignorado por ahora
			print("📘 Evento de diálogo no manejado: ", command)

func _trigger_restart() -> void:
	var logic := get_tree().get_first_node_in_group("stealth_logic")
	if logic:
		var player := get_tree().get_first_node_in_group("player")
		if player:
			player.mode = Player.Mode.DEFEATED
			await get_tree().create_timer(1.0).timeout
			SceneSwitcher.reload_with_transition(Transition.Effect.FADE, Transition.Effect.FADE)
