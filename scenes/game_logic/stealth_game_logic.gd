# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
@tool
class_name StealthGameLogic
extends Node

# ============================
# 🎯 SISTEMA DE LLAVES LOCAL
# ============================

#elian 1
var keys_collected := 0
const TOTAL_KEYS := 2

@onready var key_hud := $"../KeyHUD"  # busca el HUD de llaves en la escena
@onready var sophia_door := $"../SophIADoor"  # busca la puerta dentro de la escena
## fin elian 1

# ============================
# 🔹 FUNCIONES BASE DEL NIVEL
# ============================

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# Conectar detección de guardias
	for guard: Guard in get_tree().get_nodes_in_group(&"guard_enemy"):
		guard.player_detected.connect(self._on_player_detected)

	#elian 2
	# Reiniciar el contador de llaves al iniciar nivel
	keys_collected = 0
	if key_hud:
		key_hud.update_key_count(keys_collected, TOTAL_KEYS)
	## fin elian 2

# Cuando un guardia detecta al jugador
func _on_player_detected(player: Player) -> void:
	player.mode = Player.Mode.DEFEATED
	await get_tree().create_timer(2.0).timeout
	SceneSwitcher.reload_with_transition(Transition.Effect.FADE, Transition.Effect.FADE)

# Cuando se recoge una llave
#elian 3
func _on_key_item_key_collected() -> void:
	keys_collected += 1

	if key_hud:
		key_hud.update_key_count(keys_collected, TOTAL_KEYS)

	if keys_collected >= TOTAL_KEYS:
		print("✅ Todas las llaves recolectadas. Puerta de SophIA desbloqueada.")
		if sophia_door:
			sophia_door.open_door()
## fin elian 3
