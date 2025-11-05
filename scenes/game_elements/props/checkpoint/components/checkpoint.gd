# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
@tool
class_name Checkpoint
extends Area2D

## elian inicio - variable estática para recordar la última línea usada
static var _last_index := -1
## elian fin

const DEFAULT_SPRITE_FRAMES: SpriteFrames = preload("uid://dmg1egdoye3ns")
const REQUIRED_ANIMATIONS := [&"idle", &"appear"]

@export var sprite_frames: SpriteFrames = DEFAULT_SPRITE_FRAMES:
	set = _set_sprite_frames

## elian inicio - precargar todos los diálogos alternativos
@export var dialogues := [
	preload("res://scenes/quests/story_quests/elian/1_stealth/stealth_components/elian_checkpoint1.dialogue"),
	preload("res://scenes/quests/story_quests/elian/1_stealth/stealth_components/elian_checkpoint2.dialogue"),
	preload("res://scenes/quests/story_quests/elian/1_stealth/stealth_components/elian_checkpoint3.dialogue"),
	preload("res://scenes/quests/story_quests/elian/1_stealth/stealth_components/elian_checkpoint4.dialogue"),
	preload("res://scenes/quests/story_quests/elian/1_stealth/stealth_components/elian_checkpoint5.dialogue"),
	preload("res://scenes/quests/story_quests/elian/1_stealth/stealth_components/elian_checkpoint6.dialogue"),
	preload("res://scenes/quests/story_quests/elian/1_stealth/stealth_components/elian_checkpoint7.dialogue"),
	preload("res://scenes/quests/story_quests/elian/1_stealth/stealth_components/elian_checkpoint8.dialogue"),
	preload("res://scenes/quests/story_quests/elian/1_stealth/stealth_components/elian_checkpoint9.dialogue"),
	preload("res://scenes/quests/story_quests/elian/1_stealth/stealth_components/elian_checkpoint10.dialogue")
]
## elian fin

@export var dialogue: DialogueResource = preload("uid://bug2aqd47jgyu")
@onready var spawn_point: SpawnPoint = %SpawnPoint
@onready var sprite: AnimatedSprite2D = %Sprite
@onready var interact_area: InteractArea = %InteractArea
@onready var talk_behavior: TalkBehavior = %TalkBehavior


func _set_sprite_frames(new_sprite_frames: SpriteFrames) -> void:
	sprite_frames = new_sprite_frames
	if not is_node_ready():
		return
	if new_sprite_frames == null:
		new_sprite_frames = DEFAULT_SPRITE_FRAMES
	sprite.sprite_frames = new_sprite_frames
	update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []
	for animation: StringName in REQUIRED_ANIMATIONS:
		if not sprite_frames.has_animation(animation):
			warnings.append("sprite_frames is missing the following animation: %s" % animation)
	return warnings


func _ready() -> void:
	_set_sprite_frames(sprite_frames)
	if Engine.is_editor_hint():
		return

	talk_behavior.dialogue = dialogue
	sprite.visible = false
	body_entered.connect(func(_body: Node2D) -> void: self.activate())
	interact_area.interaction_started.connect(_on_interaction_started)
	interact_area.interaction_ended.connect(_on_interaction_ended)


func activate() -> void:
	GameState.set_current_spawn_point(owner.get_path_to(spawn_point))
	if sprite.visible:
		return

	sprite.visible = true
	sprite.play(&"appear")
	interact_area.disabled = dialogue == null
	await sprite.animation_finished
	sprite.play(&"idle")


func _on_interaction_started(_player: Player, from_right: bool) -> void:
	sprite.flip_h = from_right

	## elian inicio - elegir diálogo aleatorio diferente al anterior
	if dialogues.size() == 0:
		return

	var new_index := randi() % dialogues.size()
	if new_index == _last_index:
		new_index = (new_index + 1) % dialogues.size()

	_last_index = new_index

	talk_behavior.dialogue = dialogues[new_index]
	## elian fin


func _on_interaction_ended() -> void:
	sprite.flip_h = false
