extends Area2D
class_name Bullet

@onready var lifetime_timer = %LifetimeTimer

@export var damage: float = 0.0
@export var velocity: Vector2 = Vector2.ZERO
@export var pierce: int = 0.0

var pierced_bodies: Array[Node2D] = []

func _ready():
	lifetime_timer.connect("timeout", _on_lifetime_timer_timeout)

func shoot(with_velocity: Vector2, lifetime: float = -1):
	velocity = with_velocity
	if lifetime > 0:
		lifetime_timer.start(lifetime)

func _physics_process(delta: float) -> void:
	global_position += velocity
	if get_overlapping_bodies().size() > 0:
		var closest_body: Node2D = null
		for body: Node2D in get_overlapping_bodies():
			if body in pierced_bodies:
				continue
			var distance = global_position.distance_to(body.global_position)
			if closest_body == null or distance < global_position.distance_to(closest_body.global_position):
				closest_body = body
		if closest_body != null and closest_body.bullet_impact(self):
			pierced_bodies.append(closest_body)
			successful_hit()

func successful_hit():
	if pierced_bodies.size() > pierce:
		queue_free()

func _on_lifetime_timer_timeout() -> void:
	queue_free()
