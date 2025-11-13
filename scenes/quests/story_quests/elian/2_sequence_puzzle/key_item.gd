extends Area2D

## Esta señal avisa al KeySystem que se recogió una llave.
signal picked(key_id: String)

func _ready():
	# Opcional: conecta automáticamente la colisión con el jugador si usas un grupo "player"
	monitoring = true
	monitorable = true

func _on_body_entered(body):
	if body.is_in_group("player"):
		picked.emit(name)  # envía el nombre del nodo: "Key1" o "Key2"
		queue_free()  # elimina la llave del mapa
