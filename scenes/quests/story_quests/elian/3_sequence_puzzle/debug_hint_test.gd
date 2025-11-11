extends Node

func _ready():
	var hint = $"Sub1_HintSign1"
	if hint:
		hint.interactive_hint = true
		print("✅ Interactividad habilitada para Sub1_HintSign1")
	else:
		print("⚠️ No se encontró el nodo Sub1_HintSign1")
