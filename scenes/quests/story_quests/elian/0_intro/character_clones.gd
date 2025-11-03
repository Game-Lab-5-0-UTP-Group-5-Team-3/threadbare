extends Node2D

@export var sprite_scene: PackedScene          # Asigna character_base.tscn aquí
@export var cols_per_surface := 4
@export var rows_per_surface := 4
@export var z_index_for_clones := 999
@export var scale_65 := Vector2(0.65, 0.65)
@export var margin_px := 0

const CLONES_CONTAINER_NAME := "ClonesRuntime"

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_spawn_all()


func _spawn_all() -> void:
	if sprite_scene == null:
		push_warning("⚠️ Asigna 'Sprite Scene' en CharacterClones.")
		return

	# Eliminar clones previos
	var old := get_node_or_null(CLONES_CONTAINER_NAME)
	if old:
		old.queue_free()

	var bucket := Node2D.new()
	bucket.name = CLONES_CONTAINER_NAME
	add_child(bucket)

	var screen_wall := get_parent()
	if screen_wall == null:
		push_warning("⚠️ CharacterClones no tiene padre válido (ScreenWall).")
		return

	# Detectar las paredes tipo ColorRect
	var surfaces: Array[ColorRect] = []
	for i in range(120): # hasta ~2 segundos
		surfaces.clear()
		for child in screen_wall.get_children():
			if str(child.name).begins_with("WallSurface") and child is ColorRect:
				if child.size.x > 0 and child.size.y > 0:
					surfaces.append(child)
		if surfaces.size() >= 6:
			break
		await get_tree().process_frame

	if surfaces.is_empty():
		push_warning("⚠️ No se detectaron paredes al iniciar el juego.")
		return

	# Generar clones
	for surface in surfaces:
		var count := _spawn_on_surface(surface, bucket)
		print("✅", surface.name, "→", count, "personajes generados.")

	print("🎯 TOTAL:", surfaces.size() * cols_per_surface * rows_per_surface, "clones.")


# ===============================
# Generación proporcional por tamaño
# ===============================
func _spawn_on_surface(surface: ColorRect, bucket: Node2D) -> int:
	var rect: Rect2 = Rect2(surface.position, surface.size)

	# 🔧 Ajuste automático de densidad según tamaño
	var base_size: float = 256.0
	var scale_factor: float = surface.size.x / base_size

	# Calcula filas y columnas proporcionales (mínimo 1x1)
	var local_cols: int = max(1, int(round(cols_per_surface * scale_factor)))
	var local_rows: int = max(1, int(round(rows_per_surface * scale_factor)))

	var cell: Vector2 = rect.size / Vector2(local_cols, local_rows)
	var total_spawned: int = 0

	for r in range(local_rows):
		for c in range(local_cols):
			var inst: Node2D = sprite_scene.instantiate()
			bucket.add_child(inst)

			# Posición centrada en la celda
			var local_center: Vector2 = Vector2(c + 0.5, r + 0.5) * cell
			var global_pos: Vector2 = surface.global_position + local_center
			inst.global_position = global_pos

			# Escala al 65%
			if "scale" in inst:
				inst.scale = scale_65
			elif inst.has_method("set_scale"):
				inst.set_scale(scale_65)

			# Render encima
			if inst is CanvasItem:
				inst.z_index = z_index_for_clones
				inst.z_as_relative = false
				inst.visible = true

			# Animación si tiene AnimationPlayer
			var ap: AnimationPlayer = inst.get_node_or_null("AnimationPlayer")
			if ap:
				var names: Array[StringName] = ap.get_animation_list()
				if names.size() > 0:
					ap.play(names[0])

			total_spawned += 1

	return total_spawned
