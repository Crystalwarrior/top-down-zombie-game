@icon ("res://assets/sprites/Humanoid.png")
extends CharacterBody2D
## The class which all zombies and survivors inherit from.
##
##This class currently contains:
##Aim Pivot Logic
##Health System and Death logic
##Damage type detection (Ex. Melee or Projectile Damage)
##Weapon/Inventory System
class_name Humanoid 



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


func aim_angle(angle: float):
	%AimPivot.rotation = angle
	aim_correct()
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
#To add a weapon to an inventory, do NOT add the scene, instance, or anything. ONLY reference
#weapons by their Data/resource and instantiate things using the scene/prefab contained in that
#weapon data. Ex. data.weapon_scene.instantiate, etc.


var weapon_inventory: Array [WeaponData] = []
var current_weapon_index = -1
var current_weapon: Weapon

func add_weapon(data: WeaponData) -> void:

	weapon_inventory.append(data)
	equip_weapon(0)
	print("added " + data.name)

#
func equip_weapon(index: int) -> void:
#Checking if there are any weapons OR the player has the weapon with the high index.
	if index < 0 or index >= weapon_inventory.size():
		return
#Destros the previous weapon's node
	if current_weapon:
		current_weapon.queue_free()
#Finds the new weapons data and instantiates the scene contained in the data.
	var weapon_data = weapon_inventory[index]
	var weapon_instance = weapon_data.weapon_scene.instantiate()
	%Hand.add_child(weapon_instance)
	print("instantiated " + weapon_instance.name + 'as child of' + weapon_instance.get_parent().name)

#Logs the current weapon in the var and it's index and sets up the weapons values.
	current_weapon = weapon_instance
	current_weapon._setup_weapons(weapon_data,self)
	current_weapon_index = index

func cycle_weapon() -> void:
	if weapon_inventory.is_empty():
		return
#When the player presses the cycle weapon button, moves the index up by 1 and loops it around the
#current size of the weapon inventory using the % operator.
	current_weapon_index = (current_weapon_index + 1) % weapon_inventory.size()
	equip_weapon(current_weapon_index)
