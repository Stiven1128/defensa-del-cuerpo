extends Node2D

@onready var lbl_score   : Label         = $HUD/LblScore
@onready var lbl_time    : Label         = $HUD/LblTiempo
@onready var lbl_wave    : Label         = $HUD/LblOleada
@onready var spawner     : Node2D        = $Spawner
@onready var music       : AudioStreamPlayer = $Music
@onready var panel_nivel : Control       = $HUD/PanelNivel
@onready var panel_win   : Control       = $HUD/PanelGanaste
@onready var panel_lose  : Control       = $HUD/PanelPerdiste
@onready var panel_oleada: Control       = $HUD/PanelOleada
@onready var lbl_oleada_grande: Label    = $HUD/PanelOleada/LblOleadaGrande
@onready var corazones_container: HBoxContainer = $HUD/CorazonesContainer
@onready var panel_intro : Control       = $IntroLayer/PanelIntro

# Panel de transición de nivel
@onready var panel_nivel_nuevo: Control  = $HUD/PanelNivelNuevo
@onready var lbl_nivel_nuevo : Label = $HUD/PanelNivelNuevo/VBoxContainer/LblNivelNuevo

# Array bidimensional: historial [tiempo, evento]
var historial: Array   = []
var score: int         = 0
var tiempo: float      = 0.0
var oleada: int        = 0
var max_oleadas: int   = 4
var juego_activo: bool = false

# ─────────────────────────────────────────────────────
func _ready() -> void:
	panel_win.hide()
	panel_lose.hide()
	panel_nivel.hide()
	panel_oleada.hide()
	panel_nivel_nuevo.hide()
	spawner.detener()
	get_tree().node_added.connect(_on_nodo_agregado)

	if GameData.mostrar_selector:
		GameData.mostrar_selector = false
		panel_intro.hide()
		panel_nivel.show()
	elif GameData.nivel_actual.get("nombre", "") != "":
		panel_intro.hide()
		iniciar_juego()
	else:
		panel_intro.show()

# ── Detectar virus nuevos ─────────────────────────────
func _on_nodo_agregado(node: Node) -> void:
	if node.is_in_group("virus"):
		await node.ready
		if not node.murio.is_connected(sumar_puntos):
			node.murio.connect(sumar_puntos)

# ── Iniciar juego ─────────────────────────────────────
func iniciar_juego() -> void:
	panel_nivel.hide()
	max_oleadas = GameData.nivel_actual.get("max_oleadas", 4)
	oleada      = 0
	score       = 0
	tiempo      = 0.0

	var player = get_tree().get_first_node_in_group("player")
	if player:
		if not player.hp_changed.is_connected(_on_hp):
			player.hp_changed.connect(_on_hp)
		if not player.died.is_connected(_on_murio):
			player.died.connect(_on_murio)
		_crear_corazones(player.max_health)

	spawner.iniciar()
	if music.stream: music.play()
	juego_activo = true
	_log("Juego iniciado - Nivel: " + GameData.nivel_actual.get("nombre", "?"))
	# Mostrar primera oleada
	_siguiente_oleada()

# ─────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if not juego_activo: return
	tiempo += delta
	lbl_score.text = "❤ SCORE: %d" % score
	lbl_time.text  = "⏱ %s" % _fmt(tiempo)
	lbl_wave.text  = "🦠 OLEADA %d/%d" % [oleada, max_oleadas]

# ── Avanzar oleada ────────────────────────────────────
func _siguiente_oleada() -> void:
	oleada += 1
	_log("Oleada %d iniciada" % oleada)
	_anim_oleada()
	# Aumentar dificultad por oleada
	spawner.virus_por_oleada = GameData.nivel_actual.get("filas", 2) + (oleada - 1)
	# Verificar si terminó el nivel
	if oleada > max_oleadas:
		_nivel_completado()
		return
	# Programar siguiente oleada
	await get_tree().create_timer(20.0).timeout
	if juego_activo:
		_siguiente_oleada()

# ── Nivel completado ──────────────────────────────────
func _nivel_completado() -> void:
	juego_activo = false
	spawner.detener()
	# Eliminar virus restantes
	for v in get_tree().get_nodes_in_group("virus"):
		v.queue_free()

	if GameData.hay_siguiente_nivel():
		# Mostrar pantalla de transición al siguiente nivel
		GameData.avanzar_nivel()
		_mostrar_transicion_nivel()
	else:
		# Era el último nivel → GANASTE TOTAL
		_ganar_juego_completo()

# ── Pantalla de transición ────────────────────────────
func _mostrar_transicion_nivel() -> void:
	lbl_nivel_nuevo.text = "🏆 ¡NIVEL SUPERADO!\n\nSiguiente nivel:\n%s" % GameData.nivel_actual.get("nombre", "")
	panel_nivel_nuevo.show()
	await get_tree().create_timer(3.0).timeout
	panel_nivel_nuevo.hide()
	# Reiniciar con nuevo nivel
	get_tree().reload_current_scene()

# ── Victoria total ────────────────────────────────────
func _ganar_juego_completo() -> void:
	GameData.score_final  = score
	GameData.tiempo_final = tiempo
	$HUD/PanelGanaste/VBoxContainer/LblScoreFinal.text = "🏆 ¡COMPLETASTE TODOS LOS NIVELES!\nPuntuación: %d\nTiempo: %s" % [score, _fmt(tiempo)]
	panel_win.show()

# ── Sumar puntos ──────────────────────────────────────
func sumar_puntos(p: int) -> void:
	score += p
	_log("Virus eliminado +%d" % p)

func _on_hp(val: int) -> void:
	var corazones = corazones_container.get_children()
	for i in corazones.size():
		if i < val:
			corazones[i].text = "❤️"
			corazones[i].modulate = Color(1.0, 0.2, 0.2)
		else:
			corazones[i].text = "🖤"
			corazones[i].modulate = Color(0.3, 0.3, 0.3)
		if i == val:
			var tw = create_tween()
			tw.tween_property(corazones[i], "scale", Vector2(1.4, 1.4), 0.1)
			tw.tween_property(corazones[i], "scale", Vector2(1.0, 1.0), 0.1)

func _on_murio() -> void:
	_terminar(false)

# ── Derrota ───────────────────────────────────────────
func _terminar(gano: bool) -> void:
	juego_activo = false
	spawner.detener()
	if music.stream: music.stop()
	GameData.score_final  = score
	GameData.tiempo_final = tiempo
	_log("Fin - Ganó: %s" % str(gano))
	await get_tree().create_timer(0.8).timeout
	$HUD/PanelPerdiste/VBoxContainer/LblScoreFinal.text = "Puntuación: %d\nTiempo: %s" % [score, _fmt(tiempo)]
	panel_lose.show()

# ── Corazones ─────────────────────────────────────────
func _crear_corazones(cantidad: int) -> void:
	for c in corazones_container.get_children():
		c.queue_free()
	await get_tree().process_frame
	for i in cantidad:
		var lbl = Label.new()
		lbl.text = "❤️"
		lbl.add_theme_font_size_override("font_size", 28)
		corazones_container.add_child(lbl)

# ── Animación oleada ──────────────────────────────────
func _anim_oleada() -> void:
	lbl_oleada_grande.text = "🦠 OLEADA %d" % oleada
	panel_oleada.modulate.a = 0.0
	panel_oleada.show()
	var tw = create_tween()
	tw.tween_property(panel_oleada, "modulate:a", 1.0, 0.3)
	tw.tween_property(lbl_oleada_grande, "scale", Vector2(1.3, 1.3), 0.3)
	tw.tween_property(lbl_oleada_grande, "scale", Vector2(1.0, 1.0), 0.2)
	tw.tween_interval(1.5)
	tw.tween_property(panel_oleada, "modulate:a", 0.0, 0.4)
	await tw.finished
	panel_oleada.hide()

func _fmt(t: float) -> String:
	t = max(0.0, t)
	return "%02d:%02d" % [floori(t) / 60.0, floori(t) % 60]

func _log(evento: String) -> void:
	historial.append([tiempo, evento])

# ── Botones ───────────────────────────────────────────
func _on_btn_facil_pressed() -> void:
	GameData.nivel_idx = 0
	GameData.nivel_actual = GameData.niveles[0]
	iniciar_juego()

func _on_btn_medio_pressed() -> void:
	GameData.nivel_idx = 1
	GameData.nivel_actual = GameData.niveles[1]
	iniciar_juego()

func _on_btn_dificil_pressed() -> void:
	GameData.nivel_idx = 2
	GameData.nivel_actual = GameData.niveles[2]
	iniciar_juego()

func _on_btn_reiniciar_pressed() -> void:
	for v in get_tree().get_nodes_in_group("virus"):
		v.queue_free()
	await get_tree().process_frame
	get_tree().reload_current_scene()

func _on_btn_cambiar_nivel_pressed() -> void:
	for v in get_tree().get_nodes_in_group("virus"):
		v.queue_free()
	await get_tree().process_frame
	GameData.nivel_actual = {}
	GameData.mostrar_selector = true
	get_tree().reload_current_scene()

func _on_btn_comenzar_pressed() -> void:
	panel_intro.hide()
	panel_intro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_nivel.show()
