extends CanvasLayer

@onready var count_label: Label = null
@onready var msg_label: Label = null

func _ready():
	# Espera un frame para asegurar que los Labels estén cargados
	await get_tree().process_frame
	count_label = get_node_or_null("CountLabel")
	msg_label = get_node_or_null("MsgLabel")

	if count_label:
		count_label.text = "Llaves: 0 / 2"
	else:
		push_error("❌ No se encontró CountLabel en KeysHUD")

	if msg_label:
		msg_label.text = ""
	else:
		push_error("❌ No se encontró MsgLabel en KeysHUD")


func update_count(current: int, total: int):
	if count_label:
		count_label.text = "Llaves: %d / %d" % [current, total]


func show_message(text: String):
	if msg_label:
		msg_label.text = text
		await get_tree().create_timer(2.0).timeout
		msg_label.text = ""
