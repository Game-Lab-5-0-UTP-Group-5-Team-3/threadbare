# dialogue_pool.gd
# Controla la rotación aleatoria de los diálogos del KnitWitch (Checkpoint local).
# No usa autoload ni configuración global. Puede ser importado desde cualquier script.

class_name DialoguePool

# Lista temporal interna (la bolsa actual)
static var _bag: Array[String] = []

# Rellena y baraja la bolsa con los títulos disponibles
static func _refill() -> void:
	_bag = [
		"cp_01", "cp_02", "cp_03", "cp_04", "cp_05",
		"cp_06", "cp_07", "cp_08", "cp_09", "cp_10"
	]
	_bag.shuffle()

# Devuelve el siguiente título de diálogo (sin repetirse hasta vaciar la bolsa)
static func next_title() -> String:
	if _bag.is_empty():
		_refill()
	return _bag.pop_back()
