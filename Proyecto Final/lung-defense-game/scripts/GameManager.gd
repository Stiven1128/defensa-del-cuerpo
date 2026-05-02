extends Node2D

@onready var lbl_score  : Label              = $HUD/LblScore
@onready var lbl_time   : Label              = $HUD/LblTiempo
@onready var lbl_wave   : Label              = $HUD/LblOleada
@onready var hp_bar     : TextureProgressBar = $HUD/HPBar
@onready var spawner    : Node2D             = $Spawner
@onready var music      : AudioStreamPlayer  = $Music
@onready var panel_nivel: Control            = $HUD/PanelNivel
@onready var panel_win  : Control            = $HUD/PanelGanaste
@onready var panel_lose : Control            = $HUD/PanelPerdiste

# Array bidimensional: historial [tiempo, evento]
var historial: Array = []

var score: int         = 0
var tiempo: float      = 0.0
var limite: float      = 90.0
var oleada: int        = 1
var juego_activo: bool = false

func _ready() -> void:
	panel_win.hide()
	panel_lose.hide()
	panel_nivel.show()   # Mostrar selector de nivel al inicio
	spawner.detener()

func iniciar_juego() -> void:
	panel_nivel.hide()
	limite = GameData.nivel_actual.get("tiempo", 90)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.hp_changed.connect(_on_hp)
		player.died.connect(_on_murio)
		hp_bar.max_value = player.max_health
		hp_bar.value     = player.max_health
	spawner.iniciar()
	if music.stream: music.play()
	juego_activo = true
	_log("Juego iniciado - Nivel: " + GameData.nivel_actual.get("nombre", "?"))

func _process(delta: float) -> void:
	if not juego_activo: return
	tiempo += delta
	lbl_score.text = "❤ SCORE: %d" % score
	lbl_time.text  = "⏱ %s" % _fmt(limite - tiempo)
	lbl_wave.text  = "🦠 OLEADA %d" % oleada
	var nueva_oleada: int = int(tiempo / 20.0) + 1
	if nueva_oleada > oleada:
		oleada = nueva_oleada
		_log("Oleada %d" % oleada)
		_anim_oleada()
	if tiempo >= limite:
		_terminar(true)

func sumar_puntos(p: int) -> void:
	score += p
	_log("Virus eliminado +%d" % p)

func _on_hp(val: int) -> void:
	hp_bar.value = val

func _on_murio() -> void:
	_terminar(false)

func _terminar(gano: bool) -> void:
	juego_activo = false
	spawner.detener()
	if music.stream: music.stop()
	GameData.score_final  = score
	GameData.tiempo_final = tiempo
	_log("Fin - Ganó: %s" % str(gano))
	await get_tree().create_timer(0.8).timeout
	if gano: panel_win.show()
	else:    panel_lose.show()

func _anim_oleada() -> void:
	var tw = create_tween()
	tw.tween_property(lbl_wave, "scale", Vector2(1.5, 1.5), 0.15)
	tw.tween_property(lbl_wave, "scale", Vector2(1.0, 1.0), 0.15)

func _fmt(t: float) -> String:
	t = max(0.0, t)
	return "%02d:%02d" % [floori(t) / 60.0, floori(t) % 60]

func _log(evento: String) -> void:
	historial.append([tiempo, evento])

# Botones UI
func _on_btn_facil()   -> void: _elegir_nivel(0)
func _on_btn_medio()   -> void: _elegir_nivel(1)
func _on_btn_dificil() -> void: _elegir_nivel(2)

func _elegir_nivel(idx: int) -> void:
	var niveles = [
		{"nombre": "Fácil",   "filas": 3, "velocidad": 70,  "tiempo": 90},
		{"nombre": "Medio",   "filas": 4, "velocidad": 105, "tiempo": 70},
		{"nombre": "Difícil", "filas": 5, "velocidad": 145, "tiempo": 50}
	]
	GameData.nivel_actual = niveles[idx]
	iniciar_juego()

func _on_btn_reiniciar() -> void:
	get_tree().reload_current_scene()

func _on_btn_menu() -> void:
	get_tree().reload_current_scene()


func _on_btn_facil_pressed() -> void:
	_elegir_nivel(0)


func _on_btn_medio_pressed() -> void:
	_elegir_nivel(1)


func _on_btn_dificil_pressed() -> void:
	_elegir_nivel(2)


func _on_btn_reiniciar_pressed() -> void:
	get_tree().reload_current_scene()
