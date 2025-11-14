extends CanvasLayer

@onready var count_label: Label = $"CountLabel"
@onready var msg_label: Label   = $"MsgLabel"

func _ready() -> void:
	print("DEBUG | KeysHUD listo. CountLabel:", count_label, " MsgLabel:", msg_label)

	if count_label:
		count_label.text = "Llaves: 0 / 2"
	else:
		push_error("❌ KeysHUD: No se encontró CountLabel")

	if msg_label:
		msg_label.text = ""
	else:
		push_error("❌ KeysHUD: No se encontró MsgLabel")


func update_count(current: int, total: int) -> void:
	print("DEBUG | KeysHUD.update_count ->", current, "/", total)
	if count_label:
		count_label.text = "Llaves: %d / %d" % [current, total]


func show_message(text: String) -> void:
	if msg_label:
		msg_label.text = text
		await get_tree().create_timer(2.0).timeout
		msg_label.text = ""
