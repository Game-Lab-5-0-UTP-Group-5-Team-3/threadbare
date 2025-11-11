extends Node

@onready var key1 := $"../Interactables/Keys/Key1"
@onready var key2 := $"../Interactables/Keys/Key2"
@onready var door := $"../Interactables/Door"
@onready var hud := $"../StoryHUDs/KeysHUD"

var collected := {}

func _ready():
	key1.picked.connect(_on_key_picked)
	key2.picked.connect(_on_key_picked)
	door.tried_to_open.connect(_on_door_tried)
	hud.update_count(0, 2)

func _on_key_picked(key_id: String):
	collected[key_id] = true
	hud.update_count(collected.size(), 2)
	if collected.size() >= 2:
		door._open_door()

func _on_door_tried():
	pass

func _on_door_tried_to_open() -> void:
	pass
