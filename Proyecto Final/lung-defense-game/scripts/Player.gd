extends CharacterBody2D

@export var speed: float     = 220.0
@export var max_health: int  = 5
@export var fire_rate: float = 0.20

@onready var anim         : AnimatedSprite2D    = $AnimatedSprite2D
@onready var gun_pivot    : Node2D              = $GunPivot
@onready var shoot_point  : Marker2D            = $GunPivot/ShootPoint
@onready var hurt_overlay : ColorRect           = $HurtOverlay
@onready var snd_shoot    : AudioStreamPlayer2D = $SndShoot
@onready var snd_hurt     : AudioStreamPlayer2D = $SndHurt

const BULLET = preload("res://scenes/Bullet.tscn")

var hp: int
var shoot_cooldown: float = 0.0
var dead: bool            = false
var shooting: bool        = false

signal hp_changed(val: int)
signal died

func _ready() -> void:
	hp = max_health
	hurt_overlay.modulate.a = 0.0
	add_to_group("player")
	anim.play("idle")

func _process(delta: float) -> void:
	if dead: return
	shoot_cooldown -= delta
	_apuntar_al_mouse()
	if Input.is_action_pressed("shoot") and shoot_cooldown <= 0.0:
		_disparar()

func _physics_process(_delta: float) -> void:
	if dead: return
	var dir := Vector2(
		Input.get_axis("move_left",  "move_right"),
		Input.get_axis("move_up",    "move_down")
	).normalized()
	velocity = dir * speed
	move_and_slide()
	var vp = get_viewport_rect()
	global_position = global_position.clamp(
		vp.position + Vector2(20, 20),
		vp.end      - Vector2(20, 20)
	)
	if dir.x != 0:
		anim.flip_h = dir.x < 0
	if not shooting:
		anim.play("walk" if dir != Vector2.ZERO else "idle")

func _apuntar_al_mouse() -> void:
	gun_pivot.look_at(get_global_mouse_position())

func _disparar() -> void:
	shoot_cooldown = fire_rate
	shooting = true
	anim.play("shoot")
	await anim.animation_finished
	shooting = false
	var b = BULLET.instantiate()
	b.global_position = shoot_point.global_position
	b.rotation        = gun_pivot.rotation
	get_tree().root.add_child(b)
	if snd_shoot.stream: snd_shoot.play()

func take_damage(amount: int = 1) -> void:
	if dead: return
	hp = max(0, hp - amount)
	emit_signal("hp_changed", hp)
	anim.play("hurt")
	var tw = create_tween()
	tw.tween_property(hurt_overlay, "modulate:a", 0.55, 0.04)
	tw.tween_property(hurt_overlay, "modulate:a", 0.0,  0.20)
	if snd_hurt.stream: snd_hurt.play()
	await anim.animation_finished
	if not dead: anim.play("idle")
	if hp == 0: _morir()

func _morir() -> void:
	dead = true
	set_physics_process(false)
	anim.play("death")
	emit_signal("died")
	await anim.animation_finished
	queue_free()
