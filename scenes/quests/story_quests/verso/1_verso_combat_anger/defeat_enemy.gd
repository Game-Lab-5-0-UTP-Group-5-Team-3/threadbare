# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
extends Node

@export var intro_dialogue: DialogueResource

# AHORA SÍ: Solo 2 bosses por derrotar
var enemies_left: int = 2

signal goal_reached


func start() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player:
		player.mode = Player.Mode.FIGHTING

	# Iniciar todos los enemigos que disparan
	get_tree().call_group("throwing_enemy", "start")


func _ready() -> void:
	if intro_dialogue:
		var player: Player = get_tree().get_first_node_in_group("player")
		DialogueManager.show_dialogue_balloon(intro_dialogue, "", [self, player])
		await DialogueManager.dialogue_ended

	start()


func _update_allowed_colors() -> void:
	var allowed_labels: Array[String] = []
	var color_per_label: Dictionary[String, Color]

	for enemy: ThrowingEnemy in get_tree().get_nodes_in_group("throwing_enemy"):
		enemy.allowed_labels = allowed_labels
		enemy.color_per_label = color_per_label


# =======================================
#   DEFEAT LOGIC + CLEANUP FINAL
# =======================================
func _on_enemy_defeated() -> void:
	enemies_left -= 1
	print(">>> ENEMY DEFEATED. Remaining bosses:", enemies_left)

	if enemies_left > 0:
		return

	# ======================================================
	#       GANASTE — LIMPIEZA COMPLETA DEL NIVEL
	# ======================================================
	print(">>> ALL BOSSES DEFEATED! Cleaning NPCs...")

	# 1) Remover todos los enemigos throwing_enemy (NPC normales)
	get_tree().call_group("throwing_enemy", "remove")

	# 2) Remover todos los proyectiles activos
	get_tree().call_group("projectiles", "queue_free")

	# 3) Pasar al jugador a COZY para evitar ataques
	var player: Player = get_tree().get_first_node_in_group("player")
	if player:
		player.mode = Player.Mode.COZY

	# 4) Emitir señal final (Collectible aparece)
	print(">>> GOAL_REACHED EMITTED")
	goal_reached.emit()


func _on_boss_n_3_defeated() -> void:
	_on_enemy_defeated()


func _on_eva_defeated() -> void:
	_on_enemy_defeated()
 
