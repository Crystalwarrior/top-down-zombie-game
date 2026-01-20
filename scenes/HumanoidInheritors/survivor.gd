extends Humanoid


@export var speed = 64.0

var bullet_scene = preload("uid://dkk63rewjas47")

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

func shoot():
	var bullet: Node2D = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = %Hand.global_position
	bullet.damage = 1.0
	bullet.shoot(Vector2.from_angle(%AimPivot.rotation)*2, 2.0)
	%Audio.stream = load("res://assets/sounds/gunshot.wav")
	%Audio.play()
