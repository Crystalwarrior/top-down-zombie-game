extends CharacterBody2D

@onready var health_system: HealthSystem = %HealthSystem

@export var speed = 64.0

var bullet_scene = preload("uid://dkk63rewjas47")

func _ready() -> void:
	health_system.zero_health.connect(_on_zero_health)

func _physics_process(_delta: float) -> void:
	var direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	if direction.length() > 0:
		direction = direction.normalized()
	velocity = direction * speed

	move_and_slide()

func _process(_delta: float) -> void:
	aim_at(get_global_mouse_position())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot()

func aim_at(pos: Vector2):
	%AimPivot.look_at(pos)
	aim_correct()

func aim_correct():
	var test = abs(wrapf(%AimPivot.rotation_degrees, 0, 360))
	if test >= 90 and test <= 270:
		%Hand.scale.y = -1
		%Body.scale.x = -1
	else:
		%Hand.scale.y = 1
		%Body.scale.x = 1

func shoot():
	var bullet: Node2D = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = %Hand.global_position
	bullet.damage = 1.0
	bullet.shoot(Vector2.from_angle(%AimPivot.rotation)*2, 2.0)
	%Audio.stream = load("res://assets/sounds/gunshot.wav")
	%Audio.play()


func melee_impact(cause: Node2D):
	health_system.hurt(cause.melee_damage)
	if health_system.health <= 0:
		return true
	if hurt_tween:
		hurt_tween.kill()
	hurt_tween = create_tween().set_parallel(true)
	var body: Node2D = %Body
	var hand: Node2D = %Hand
	body.self_modulate = Color(5.0, 0.0, 0.0)
	hurt_tween.tween_property(body, "self_modulate", Color.WHITE, 0.2)
	hand.modulate = Color(5.0, 0.0, 0.0)
	hurt_tween.tween_property(hand, "modulate", Color.WHITE, 0.2)
	return true

var hurt_tween: Tween
func _on_zero_health():
	set_process(false)
	set_physics_process(false)
	%Audio.stream = load("res://assets/sounds/gorekill.wav")
	%Audio.play()
	if hurt_tween:
		hurt_tween.kill()
	hurt_tween = create_tween().set_parallel(true)
	var body: Node2D = %Body
	var hand: Node2D = %Hand
	body.self_modulate = Color(5.0, 0.0, 0.0)
	hurt_tween.tween_property(body, "self_modulate", Color.RED, 0.2)
	hand.modulate = Color(5.0, 0.0, 0.0)
	hurt_tween.tween_property(hand, "modulate", Color.RED, 0.2)
	await hurt_tween.finished
	print("GAME OVER BITCH")
