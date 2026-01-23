extends Weapon

const thisWeaponTexture: Texture2D = preload("res://assets/sprites/pistol.png")

func _ready() -> void:
	weapon_name = "Pistol"
	bullet = preload("uid://dkk63rewjas47")
	description = "A normal pistol."
	sprite.texture = thisWeaponTexture
