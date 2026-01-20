extends CharacterBody2D


@onready var health_system: HealthSystem = %HealthSystem

# Declare new NavAgent2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@export var speed = 63.0

@export var melee_distance = 24

@export var melee_damage = 1

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	health_system.zero_health.connect(_on_zero_health)

func _physics_process(_delta: float) -> void:
	var closest_enemy = null
	var closest_distance
	for enemy in %ScanArea.get_overlapping_bodies():
		var enemy_distance = global_position.distance_to(enemy.global_position)
		if closest_enemy == null or enemy_distance < closest_enemy.global_position.distance_to(global_position):
			closest_enemy = enemy
			closest_distance = enemy_distance

	direction = Vector2.ZERO
	if closest_enemy:
		#Set the zombie's target position
		nav_agent.target_position = closest_enemy.global_position
		
		#Log the values created by nav_mesh to correctly set the objects position
		var current_pos = self.global_position
		var next_path_position = nav_agent.get_next_path_position()
		var new_velocity = current_pos.direction_to(next_path_position) * speed
		
		#Check if the path is valid or not, if not velocity will be set to zero and new path will be calculated.
		if nav_agent.avoidance_enabled :
			nav_agent.set_velocity(new_velocity)
		#If no obstacles are detected, set the velocity to the new direction.
		else:
			_on_navigation_agent_2d_velocity_computed(new_velocity)
		aim_angle(new_velocity.angle())
		move_and_slide()
		
		if closest_distance <= melee_distance:
			%AttackAnimationPlayer.play("claw")

	if closest_enemy in %HurtZone.get_overlapping_bodies():
		if closest_enemy.melee_impact(self):
			%Audio.stream = load("res://assets/sounds/tear.wav")
			%Audio.play()
			%HurtCollision.disabled = true



func aim_at(pos: Vector2):
	%AimPivot.look_at(pos)
	aim_correct()

func aim_angle(angle: float):
	%AimPivot.rotation = angle
	aim_correct()

func aim_correct():
	var test = abs(wrapf(%AimPivot.rotation_degrees, 0, 360))
	if test >= 90 and test <= 270:
		%Hand.scale.y = -1
		%Body.scale.x = -1
	else:
		%Hand.scale.y = 1
		%Body.scale.x = 1

var hurt_tween: Tween
func bullet_impact(bullet: Bullet) -> bool:
	health_system.hurt(bullet.damage)
	if health_system.health <= 0:
		return true
	%Audio.stream = load("res://assets/sounds/gorehit.wav")
	%Audio.play()
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

func _on_zero_health():
	%ScanShape.disabled = true
	%BumpShape.disabled = true
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
	hurt_tween.tween_property(body, "self_modulate", Color.TRANSPARENT, 0.2)
	hand.modulate = Color(5.0, 0.0, 0.0)
	hurt_tween.tween_property(hand, "modulate", Color.TRANSPARENT, 0.2)
	await hurt_tween.finished
	queue_free()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	#This method is just filtering the velocity after the nav mesh has correctly set it.
