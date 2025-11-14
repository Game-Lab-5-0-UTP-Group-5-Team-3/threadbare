extends Area2D

## Señal para KeySystem
signal picked(key_id: String)

@onready var pick_sound: AudioStreamPlayer2D = $PickpSound

func _ready():
	monitoring = true
	monitorable = true
	# ❌ NO conectamos body_entered aquí
	# porque ya está conectado desde el editor


func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	# Avisar al KeySystem
	picked.emit(name)

	# Reproducir sonido si existe
	if pick_sound and pick_sound.stream:
		pick_sound.play()
		await get_tree().create_timer(0.25).timeout

	# Remover la llave del mapa
	queue_free()
