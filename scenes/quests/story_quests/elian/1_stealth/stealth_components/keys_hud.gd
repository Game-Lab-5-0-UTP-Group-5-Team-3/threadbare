extends CanvasLayer

@onready var label := $CountLabel
@onready var msg := $MsgLabel

func _ready():
	label.visible = false
	msg.visible = false

func update_count(current: int, total: int):
	label.text = "Llaves: " + str(current) + " / " + str(total)
	label.visible = true

func show_message(text: String):
	msg.text = text
	msg.visible = true
	await get_tree().create_timer(2.0).timeout
	msg.visible = false
