extends CharacterBody2D

@export var max_hp: int  = 2
@export var damage: int  = 1
@export var points: int  = 10
var custom_speed: float  = 90.0

@onready var anim    : AnimatedSprite2D    = $AnimatedSprite2D
@onready var hp_bar  : ProgressBar         = $HPBar
@onready var snd_die : AudioStreamPlayer2D = $SndDie
@onready var snd_hit : AudioStreamPlayer2D = $SndHit

signal murio(puntos: int)

var hp: int
var player: Node2D = null
var muerto: bool   = false

# ─────────────────────────────────────────────────────
func _ready() -> void:
	# HP según nivel
	var hp_nivel = GameData.nivel_actual.get("hp_virus", 1)
	max_hp = hp_nivel
	hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value     = max_hp
	add_to_group("virus")
	player = get_tree().get_first_node_in_group("player")
	anim.play("idle")
	# Conectar al GameManager
	var gm = get_tree().get_root().get_node_or_null("Main")
	if gm and gm.has_method("sumar_puntos"):
		murio.connect(gm.sumar_puntos)

func _physics_process(_delta: float) -> void:
	if muerto or player == null: return
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * custom_speed
	anim.flip_h = velocity.x < 0
	anim.play("move")
	move_and_slide()

func take_damage(amt: int) -> void:
	if muerto: return
	hp -= amt
	hp_bar.value = hp
	if snd_hit.stream: snd_hit.play()
	var tw = create_tween()
	tw.tween_property(anim, "modulate", Color(3, 3, 3), 0.04)
	tw.tween_property(anim, "modulate", Color.WHITE,    0.10)
	if hp <= 0: _morir()

func _morir() -> void:
	muerto = true
	if snd_die.stream: snd_die.play()
	$CollisionShape2D.set_deferred("disabled", true)
	anim.play("death")
	emit_signal("murio", points)
	await anim.animation_finished
	queue_free()

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
