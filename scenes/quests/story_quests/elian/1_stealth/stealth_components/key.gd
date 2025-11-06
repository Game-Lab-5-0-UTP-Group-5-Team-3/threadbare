extends Area2D

@export var key_id: String = "key_1"
signal picked(key_id: String)

@onready var pickup_sound: Node = $PickupSound  # 🎵 compatible con AudioStreamPlayer o AudioStreamPlayer2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":
		## 🎵 SONIDO INICIO
		if is_instance_valid(pickup_sound) and pickup_sound.has_method("play"):
			print_debug("[KEY]", key_id, "→ Reproduciendo sonido...")
			pickup_sound.play()
		else:
			print_debug("[KEY]", key_id, "→ ⚠️ No se puede reproducir sonido (no tiene método 'play').")
		## 🎵 SONIDO FIN

		emit_signal("picked", key_id)
		await get_tree().create_timer(0.15).timeout
		queue_free()
