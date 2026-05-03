extends Node2D

const VIRUS_SCENE = preload("res://scenes/Virus.tscn")

# Array bidimensional: zonas de spawn [zona][punto]
var spawn_zones: Array = [
	[Vector2(-40, 100), Vector2(-40, 360), Vector2(-40, 580)],
	[Vector2(1320, 100), Vector2(1320, 360), Vector2(1320, 580)],
	[Vector2(300, -40), Vector2(640, -40), Vector2(980, -40)],
	[Vector2(300, 760), Vector2(640, 760), Vector2(980, 760)]
]

var virus_speed: float      = 90.0
var virus_por_oleada: int   = 3
var intervalo: float        = 2.5
var _timer: float           = 0.0
var activo: bool            = false

func _ready() -> void:
	virus_speed      = GameData.nivel_actual.get("velocidad", 55)
	virus_por_oleada = GameData.nivel_actual.get("filas", 2)
	intervalo        = GameData.nivel_actual.get("intervalo", 4.0)

func iniciar() -> void: activo = true
func detener() -> void: activo = false

func _process(delta: float) -> void:
	if not activo: return
	_timer += delta
	if _timer >= intervalo:
		_timer = 0.0
		_oleada()
		intervalo = max(0.6, intervalo - 0.04)

func _oleada() -> void:
	# Validación y aleatoriedad: elegir zona y punto aleatorios
	var zona: Array  = spawn_zones[randi() % spawn_zones.size()]
	var pos: Vector2 = zona[randi() % zona.size()]
	for i in virus_por_oleada:
		var offset = Vector2(randf_range(-25, 25), randf_range(-25, 25))
		_crear_virus(pos + offset)

func _crear_virus(pos: Vector2) -> void:
	var v = VIRUS_SCENE.instantiate()
	v.global_position = pos
	v.custom_speed    = virus_speed
	get_tree().root.add_child(v)
