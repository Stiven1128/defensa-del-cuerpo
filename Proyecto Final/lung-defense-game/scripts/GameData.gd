extends Node

# Niveles disponibles
var niveles: Array = [
	{
		"nombre": "Fácil",
		"filas": 2,
		"velocidad": 55,
		"intervalo": 4.0,
		"hp_virus": 1,
		"max_oleadas": 4
	},
	{
		"nombre": "Medio",
		"filas": 3,
		"velocidad": 90,
		"intervalo": 2.5,
		"hp_virus": 2,
		"max_oleadas": 4
	},
	{
		"nombre": "Difícil",
		"filas": 5,
		"velocidad": 140,
		"intervalo": 1.5,
		"hp_virus": 3,
		"max_oleadas": 4
	}
]

var nivel_idx: int        = 0   # índice del nivel actual (0=Fácil, 1=Medio, 2=Difícil)
var nivel_actual: Dictionary = {}
var score_final: int      = 0
var tiempo_final: float   = 0.0
var mostrar_selector: bool = false

func get_nivel() -> Dictionary:
	return niveles[nivel_idx]

func hay_siguiente_nivel() -> bool:
	return nivel_idx < niveles.size() - 1

func avanzar_nivel() -> void:
	if hay_siguiente_nivel():
		nivel_idx += 1
		nivel_actual = niveles[nivel_idx]
