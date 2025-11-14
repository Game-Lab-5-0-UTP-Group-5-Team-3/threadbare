extends Area2D

@export var chaser_path: NodePath
@export var door_path: NodePath     # ← añadimos la referencia opcional a la puerta

func _ready():
	body_entered.connect(_on_entered)


func _on_entered(body):
	if not body.is_in_group("player"):
		return

	# -----------------------------------------
	# 1) ACTIVAR EL BLACK HOLE (tu lógica original)
	# -----------------------------------------
	if chaser_path != NodePath(""):
		var chaser = get_node(chaser_path)
		if chaser:
			chaser.active = true
			print("> BLACK HOLE ACTIVADO desde chase_trigger")

	# -----------------------------------------
	# 2) ABRIR LA PUERTA (si se asignó)
	# -----------------------------------------
	if door_path != NodePath(""):
		var door = get_node(door_path)
		if door and door.has_method("open_door"):
			print("> PUERTA ABIERTA desde chase_trigger")
			door.open_door()

	# -----------------------------------------
	# 3) ELIMINAR EL TRIGGER PARA QUE NO SE REPITA
	# -----------------------------------------
	queue_free()
