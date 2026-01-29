extends Humanoid

# Declare new NavAgent2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@export var speed = 63.0

@export var melee_distance = 24

@export var melee_damage = 1

var direction: Vector2 = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	var closest_enemy = null
	var closest_distance
	for enemy in %ScanArea.get_overlapping_bodies():
		var enemy_distance = global_position.distance_to(enemy.global_position)
		if closest_enemy == null or enemy_distance < closest_enemy.global_position.distance_to(global_position):
			closest_enemy = enemy
			closest_distance = enemy_distance

	move_and_slide()

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




func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
