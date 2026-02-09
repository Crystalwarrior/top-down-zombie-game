@icon ("res://assets/sprites/zombie/Weapon.png")
extends Node
class_name Weapon

var data: WeaponData
var weapon_owner: Humanoid
var can_attack: bool = true

func _setup_weapons(this_data: WeaponData, this_owner: Humanoid ) -> void:
	data = this_data
	weapon_owner = this_owner

func use_weapon() -> void:
	if can_attack == false:
		return
	else:
#Calls the attack on function after gating through can_attack
		can_attack = false
		attack()
#Creates a new timer node, 
#lasting for a second followed by opening the can_attack gate again after the timer runs out
		await get_tree().create_timer(1.0 / data.attack_rate).timeout
		can_attack = true

func attack() -> void:
	var bullet: Node2D = data.bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = self.get_parent().global_position
	bullet.damage = 1.0
	bullet.shoot(Vector2.from_angle(self.get_parent().global_rotation)*2, 2.0)
	$Audio.stream = load("res://assets/sounds/gunshot.wav")
	$Audio.play()
