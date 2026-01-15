extends CharacterBody2D

@onready var health_system: HealthSystem = %HealthSystem

@export var speed = 64.0

var bullet_scene = preload("uid://dkk63rewjas47")

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	var direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	velocity = direction * speed

	move_and_slide()

func _process(delta: float) -> void:
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

func bullet_impact(bullet: Bullet):
	pass
