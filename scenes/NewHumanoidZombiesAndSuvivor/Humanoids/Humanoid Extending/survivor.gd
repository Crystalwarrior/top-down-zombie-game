
extends Humanoid


@export var speed = 64.0

var bullet_scene = preload("uid://dkk63rewjas47")

#Change/add/remove starting weapon data in the inspector!
@export var starting_weapons : Array[WeaponData]

func _ready() -> void:
	for weapon in starting_weapons:
		add_weapon(weapon)

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
		use_weapon()
		if event.is_action_pressed("changeweapon"):
			cycle_weapon()

func use_weapon():
	if weapon_inventory.size() == 0:
		print ("Oh Shit I'm unarmed!")
		return
	else:
		print("I have a weapon! Let me shoot it!")
		current_weapon.use_weapon()
	
