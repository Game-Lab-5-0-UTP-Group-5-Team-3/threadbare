extends CanvasLayer
class_name KeyHUD

@onready var label: Label = null

func _ready() -> void:
	# Espera un frame para asegurarse de que todo esté cargado
	await get_tree().process_frame
	label = $MarginContainer/HBoxContainer/Label
	label.text = "🔑 0 / 2"

func update_key_count(collected: int, total: int) -> void:
	if label == null:
		label = $MarginContainer/HBoxContainer/Label
	label.text = "🔑 %d / %d" % [collected, total]
