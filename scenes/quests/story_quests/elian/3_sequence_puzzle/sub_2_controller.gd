extends Node

enum Mode { NONE, GOOD, BAD }
var mode: Mode = Mode.NONE

# === CONFIGURACIÓN DE SUB2 ===
@onready var step_bad: SequencePuzzleStep = $"Sub2_SequencePuzzleStep1"
@onready var step_good: SequencePuzzleStep = $"Sub2_SequencePuzzleStep2"
@onready var key_system := $"../KeySystem"
@onready var player := get_tree().get_first_node_in_group("player") # 🎮 referencia directa al jugador
var key_id := "Key2"
# =====================================================

var _cursor := 0
var current_sequence: Array = []
var sub2_completed := false   # ✅ Nuevo: bandera de completado


func _ready() -> void:
	print("🔍 Buscando botones dentro de Sub2Controller...")
	for child in get_children():
		if child is SequencePuzzleObject:
			child.kicked.connect(_on_button_kicked.bind(child))
			print("✅ Conectado botón manual:", child.name)

	var good_sign = $"Sub2_HintSign2"
	var bad_sign = $"Sub2_HintSign1"

	if good_sign:
		good_sign.interactive_hint = true
	if bad_sign:
		bad_sign.interactive_hint = true

	print("✅ Sub2Controller inicializó los HintSigns como interactivos.")

	# === Personalizar texto de acción de los carteles ===
	if bad_sign and bad_sign.has_node("InteractArea"):
		var area = bad_sign.get_node("InteractArea")
		area.action = "Seguir Partitura"  # 🎼 cartel BAD
		print("🎵 Acción del cartel malo cambiada a 'Seguir Partitura'")

	if good_sign and good_sign.has_node("InteractArea"):
		var area = good_sign.get_node("InteractArea")
		area.action = "Improvisar"  # 🎭 cartel GOOD
		print("🎵 Acción del cartel bueno cambiada a 'Improvisar'")


func _reset():
	mode = Mode.NONE
	_cursor = 0
	current_sequence.clear()


# =======================
# 💠 Interacción con carteles (solo pista, con sonido)
# =======================
func _on_good_sign_demo() -> void:
	print("👁️ HINT: Mostrando secuencia buena (con sonido).")
	_show_hint_sequence(step_good.sequence, $"Sub2_HintSign2")

func _on_bad_sign_demo() -> void:
	print("👁️ HINT: Mostrando secuencia mala (con sonido).")
	_show_hint_sequence(step_bad.sequence, $"Sub2_HintSign1")


func _show_hint_sequence(sequence: Array, sign: Node) -> void:
	print("▶ Reproduciendo demostración visual:", sign.name)
	for btn in sequence:
		if btn and btn.has_method("play"):
			btn.play()
			await get_tree().create_timer(0.6).timeout
	await get_tree().create_timer(0.3).timeout
	if sign and sign.has_method("demonstration_finished"):
		sign.demonstration_finished()
	print("✅ Demostración de pista completada para:", sign.name)


# =======================
# 🧩 Secuencia jugable libre (deducción automática)
# =======================
func _on_button_kicked(button: Node) -> void:
	if not button:
		return

	var button_name := button.name
	print("🚀 Botón presionado:", button_name)

	# 1️⃣ Detectar si hay secuencia activa o debemos iniciar una
	if mode == Mode.NONE:
		if button_name == step_good.sequence[0].name:
			mode = Mode.GOOD
			current_sequence = step_good.sequence.duplicate()
			_cursor = 0
			print("🟢 Secuencia BUENA iniciada automáticamente.")
		elif button_name == step_bad.sequence[0].name:
			mode = Mode.BAD
			current_sequence = step_bad.sequence.duplicate()
			_cursor = 0
			print("🔴 Secuencia MALA iniciada automáticamente.")
		else:
			print("⚠️ No se inició secuencia: el botón no pertenece a ningún inicio.")
			return

	if current_sequence.is_empty():
		print("⚠️ current_sequence vacía, no hay secuencia activa.")
		return

	var expected_button_name: String = current_sequence[_cursor].name
	print("🔍 Comparando:", button_name, "vs", expected_button_name)

	# Reproduce sonido/animación
	if button.has_method("play"):
		button.play()

	# 2️⃣ Si se equivoca, reinicia y verifica si inicia otra secuencia
	if button_name != expected_button_name:
		print("❌ Botón incorrecto:", button_name, "→ Esperado:", expected_button_name)

		var other_mode := Mode.NONE
		if button_name == step_good.sequence[0].name:
			other_mode = Mode.GOOD
		elif button_name == step_bad.sequence[0].name:
			other_mode = Mode.BAD

		_reset()

		# Si ese botón inicia otra secuencia, lánzala automáticamente
		if other_mode != Mode.NONE:
			mode = other_mode
			current_sequence = (step_good.sequence if other_mode == Mode.GOOD else step_bad.sequence).duplicate()
			_cursor = 1
			print("🔁 Cambio automático → Nueva secuencia iniciada:", ("GOOD" if mode == Mode.GOOD else "BAD"))
		return

	# 3️⃣ Acierto parcial
	_cursor += 1
	print("✅ Acierto parcial:", _cursor, "/", current_sequence.size())

	# 4️⃣ Secuencia completa
	if _cursor >= current_sequence.size():
		if mode == Mode.GOOD:
			await _handle_sequence_completed($"Sub2_HintSign2", "GOOD")
		else:
			await _handle_sequence_completed($"Sub2_HintSign1", "BAD")
		_reset()
		return


# =======================
# 🪄 Marcar cartel como solved y aplicar efecto
# =======================
func _handle_sequence_completed(sign: Node, label: String) -> void:
	print("🔔 Secuencia", label, "completada → marcando", sign.name)

	# Si ya se completó el subnivel, ignorar muertes futuras
	if sub2_completed and label == "BAD":
		print("🔒 Subnivel completado, ignorando secuencia mala (sin muerte).")
		return

	if sign and sign.has_method("set_solved"):
		sign.set_solved()
		print("✅ is_solved = true para", sign.name)

	await get_tree().process_frame

	if sign and sign.has_method("update_solved_state"):
		sign.update_solved_state()
		print("🎨 update_solved_state() ejecutado para", sign.name)

	match label:
		"GOOD":
			sub2_completed = true   # ✅ Marcamos subnivel como completado
			# 🔑 Activar llave física
			var key2 := $"../../Interactables/Keys/Key2"
			if key2:
				key2.visible = true
				var shape := key2.get_node_or_null("CollisionShape2D")
				if shape:
					shape.disabled = false
				print("🔑 Key2 activada en el mundo. El jugador puede recogerla ahora.")
			else:
				print("🚨 No se encontró Key2 en ../../Interactables/Keys/")

		"BAD":
			# 💀 Muerte del jugador con animación + delay (1.2s)
			if is_instance_valid(player):
				player.mode = player.Mode.DEFEATED
				var anim_names: PackedStringArray = player.player_sprite.sprite_frames.get_animation_names()
				if "defeated" in anim_names:
					player.player_sprite.play("defeated")
					print("💀 Animación 'defeated' reproducida correctamente.")
			await get_tree().create_timer(1.2).timeout
			print("💀 Secuencia MALA completada → Reiniciando escena...")
			get_tree().reload_current_scene()
