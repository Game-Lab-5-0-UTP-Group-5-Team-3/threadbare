# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
class_name FillGameLogic
extends Node
## Manages the logic of the fill-matching game.
##
## Grabs the label and optional color of each FillingBarrel that exist in the
## current scene, and assigns them as the allowed label/color of the Projectile
## that each ThrowingEnemy is allowed to throw.
##
## Each time a FillingBarrel is filled, perform the label/color assignment again
## so ThrowingEnemy only throw projectiles that can increase the amount of the
## remaining barrels.
##
## Emits `goal_reached` when all required barrels are filled.

signal goal_reached

## How many barrels must be completed to win.
@export var barrels_to_win: int = 1

@export var intro_dialogue: DialogueResource

## Counter for how many are done.
var barrels_completed: int = 0


func start() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player:
		player.mode = Player.Mode.FIGHTING

	get_tree().call_group("throwing_enemy", "start")

	for filling_barrel: FillingBarrel in get_tree().get_nodes_in_group("filling_barrels"):
		filling_barrel.completed.connect(_on_barrel_completed)

	_update_allowed_colors()


func _ready() -> void:
	var filling_barrels: Array = get_tree().get_nodes_in_group("filling_barrels")
	barrels_to_win = clampi(barrels_to_win, 0, filling_barrels.size())

	if intro_dialogue:
		var player: Player = get_tree().get_first_node_in_group("player")
		DialogueManager.show_dialogue_balloon(intro_dialogue, "", [self, player])
		await DialogueManager.dialogue_ended

	start()


func _update_allowed_colors() -> void:
	var allowed_labels: Array[String] = []
	var color_per_label: Dictionary[String, Color]

	for filling_barrel: FillingBarrel in get_tree().get_nodes_in_group("filling_barrels"):
		if filling_barrel.is_queued_for_deletion():
			continue

		if filling_barrel.label not in allowed_labels:
			allowed_labels.append(filling_barrel.label)

			if filling_barrel.color:
				color_per_label[filling_barrel.label] = filling_barrel.color

	for enemy: ThrowingEnemy in get_tree().get_nodes_in_group("throwing_enemy"):
		enemy.allowed_labels = allowed_labels
		enemy.color_per_label = color_per_label


func _on_barrel_completed() -> void:
	barrels_completed += 1
	_update_allowed_colors()

	if barrels_completed < barrels_to_win:
		return

	# =============================================
	#   FIX PARA QUE LOS NPC SIGAN DISPARANDO
	# =============================================
	# Cuando ya no hay barrels, allowed_labels queda vacío → NPC deja de disparar.
	# Por eso, después de completar el target asignamos un label fijo.
	for enemy: ThrowingEnemy in get_tree().get_nodes_in_group("throwing_enemy"):
		enemy.allowed_labels = ["default"]     # etiqueta válida
		enemy.color_per_label = {}             # sin color

	# =============================================
	#   FINALIZAR SUBNIVEL, PASAR AL COMBATE
	# =============================================
	print(">>> FillGameLogic COMPLETED → goal_reached")
	goal_reached.emit()


func _on_boss_n_3_defeated() -> void:
	pass


func _on_eva_defeated() -> void:
	pass
