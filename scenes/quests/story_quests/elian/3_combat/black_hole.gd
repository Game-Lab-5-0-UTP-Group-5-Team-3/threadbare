extends Node2D

@export var speed: float = 40.0
@export var start_position: Vector2
@export var end_position: Vector2

var active := false
var already_killed := false   # ← evita doble muerte


func _ready():
	# Colocar al BlackHole en el punto inicial
	position = start_position

	# Conectar colisión
	if $Area2D:
		$Area2D.body_entered.connect(_on_body_entered)
	else:
		print("⚠ BlackHole: NO TIENE Area2D, no podrá detectar colisiones")


func _process(delta):
	# Si está activo, se mueve hacia el final
	if active:
		position = position.move_toward(end_position, speed * delta)


func _on_body_entered(body):
	# Evitar muerte doble
	if already_killed:
		return
	
	# Verificar que sea el jugador
	if not body.is_in_group("player"):
		return

	already_killed = true
	print("PLAYER KILLED BY BLACK HOLE")

	# 1. Detener movimiento del BlackHole
	active = false

	# 2. Matar jugador con animación nativa
	body.mode = body.Mode.DEFEATED
	body.velocity = Vector2.ZERO

	# 3. Añadir un delay para ver la animación
	await get_tree().create_timer(1.6).timeout

	# 4. Reiniciar escena
	get_tree().reload_current_scene()
