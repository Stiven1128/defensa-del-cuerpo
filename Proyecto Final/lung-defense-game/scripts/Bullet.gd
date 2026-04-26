extends Area2D

@export var speed: float = 620.0
@export var damage: int  = 1

var dir: Vector2 = Vector2.RIGHT

func _ready() -> void:
	dir = Vector2.RIGHT.rotated(rotation)
	get_tree().create_timer(2.0).timeout.connect(queue_free)
	body_entered.connect(_on_hit)

func _process(delta: float) -> void:
	position += dir * speed * delta

func _on_hit(body: Node) -> void:
	if body.is_in_group("virus"):
		body.take_damage(damage)
		_destruir()

func _destruir() -> void:
	set_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(2.0, 2.0), 0.06)
	tw.parallel().tween_property(self, "modulate:a", 0.0, 0.08)
	await tw.finished
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
