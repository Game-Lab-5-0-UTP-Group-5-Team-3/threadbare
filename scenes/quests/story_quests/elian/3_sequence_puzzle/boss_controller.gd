extends Node

# 🎭 BossController: controla el comportamiento del BossNPC según el progreso del nivel final.

@onready var boss := $"BossNPC"
@onready var hint1 := $"../Signs/HintSign1"
@onready var hint2 := $"../Signs/HintSign2"

# 💬 Rutas a los diálogos del Boss
@export var boss_idle_dialogue: DialogueResource
@export var boss_phase2_dialogue: DialogueResource

var hint1_done := false
var hint2_done := false


func _ready() -> void:
	print("🧩 BossController listo — escuchando los HintSigns...")

	if not boss or not hint1 or not hint2:
		push_warning("⚠️ BossController: no se encontraron todos los nodos esperados.")
		return

	set_process(true)


func _process(_delta: float) -> void:
	# Detectar cuándo los carteles pasan a estado solved
	if hint1 and not hint1_done and _is_solved(hint1):
		hint1_done = true
		_on_hint1_completed()

	if hint2 and not hint2_done and _is_solved(hint2):
		hint2_done = true
		_on_hint2_completed()


func _is_solved(sign: Node) -> bool:
	# 🧩 Verifica si el cartel tiene la propiedad is_solved = true
	return sign.get("is_solved") == true


# ===========================
# 🎭 Reacciones del Boss
# ===========================

func _on_hint1_completed() -> void:
	if not boss or not is_instance_valid(boss):
		return
	if not boss_phase2_dialogue:
		push_warning("⚠️ No se asignó boss_phase2_dialogue.")
		return

	var talk := boss.get_node_or_null("TalkBehavior")
	if talk:
		talk.dialogue = boss_phase2_dialogue
		print("💬 Boss cambió a diálogo fase 2.")
	else:
		push_warning("⚠️ BossNPC no tiene TalkBehavior asignado.")


func _on_hint2_completed() -> void:
	if not boss or not is_instance_valid(boss):
		return

	# 💀 Desactivar completamente el Boss
	boss.visible = false
	boss.process_mode = Node.PROCESS_MODE_DISABLED
	boss.set_physics_process(false)

	for child in boss.get_children():
		# Solo los nodos con visibilidad
		if child is CanvasItem:
			child.visible = false
		if child.has_method("set_process"):
			child.set_process(false)

	print("💀 Boss y su TalkBehavior desactivados completamente tras la segunda secuencia.")
