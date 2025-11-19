extends Node2D

signal tried_to_open

@export var open_animation_time := 0.4
@export var open_sound: AudioStream   # sonido opcional


func _ready() -> void:
	if has_node("InteractArea"):
		$InteractArea.input_event.connect(_on_interact)


func _on_interact(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("interact"):
		tried_to_open.emit()


func _open_door() -> void:
	print(">>> Door opening with SHAKE!")

	# ============================
	# 🔊 SONIDO (si fue asignado)
	# ============================
	if open_sound:
		$OpenSound.stream = open_sound
		$OpenSound.play()

	# ============================
	# 🔥 EFECTO DE TEMBLOR FUERTE
	# ============================
	var shake_tween := create_tween()
	var original_pos := position
	
	# Temblor de 0.30s, fuerte → ±6 píxeles
	var shake_strength := 6
	var shake_duration := 0.30
	var shake_speed := 0.03  # sacudidas rápidas

	var elapsed := 0.0
	while elapsed < shake_duration:
		shake_tween.tween_property(self, "position",
			original_pos + Vector2(
				randf_range(-shake_strength, shake_strength),
				randf_range(-shake_strength, shake_strength)
			),
			shake_speed
		)
		elapsed += shake_speed

	# Volver a la posición original antes de la animación de fade
	shake_tween.tween_property(self, "position", original_pos, 0.05)

	# ============================
	# 🌫️ FADE-OUT / DESVANECERSE
	# ============================
	var fade_tween := create_tween()
	fade_tween.tween_property($Sprite2D, "modulate:a", 0.0, open_animation_time)

	# ============================
	# 🚪 DESACTIVAR COLISIÓN
	# ============================
	$CollisionShape2D.set_deferred("disabled", true)
