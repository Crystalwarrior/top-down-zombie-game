extends CharacterBody2D
class_name Humanoid ## The class which all zombies and survivors inherit from.
##
##This class currently contains:
##Aim Pivot Logic
##Health System and Death logic
##Damage type detection (Ex. Melee or Projectile Damage)
##Weapon/Inventory System



@onready var health_system: HealthSystem = $HealthSystem

@onready var inventory_system: InventorySystem = $Inventory

#----
#Connections
#-----

func _ready() -> void:
	#Connecting the signal on the HealthSystem script to a local function.
	health_system.zero_health.connect(_on_zero_health)


#-----
# Aim System
#-----

#Tells the characters aim pivot what to look at. 
#Ex. On Survivor: pos = mouse.location, On Zombie: pos = survivor.location
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

#-----
# Health System
#-----

#Handles death when the humanoid's HealthSystem script signals to this function.
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
	queue_free()

#Whenever the character detects the damage caused to it was by a melee attack.
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

#Whenever the character detects the damage caused to it was by a projectile.
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

#-----
#Weapons and Inventory
#-----

#Give the humanoid a weapon on spawn by signalling to the Inventory System script.
func _startWeapon(weapon: String) :
	inventory_system.add_item(weapon)
