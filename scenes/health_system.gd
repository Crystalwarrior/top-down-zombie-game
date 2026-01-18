extends Node
class_name HealthSystem

@export var health = 10.0
@export var max_health = 10.0

signal changed
signal damaged(by: float)
signal healed(by: float)
signal zero_health

func set_health(value: float):
	var old_health = health
	health = max(0, min(value, max_health))
	var difference = health - old_health
	if difference > 0:
		healed.emit(difference)
	elif difference < 0:
		damaged.emit(difference)
		if health <= 0:
			zero_health.emit()
	changed.emit()

func heal(value: float):
	set_health(health + value)

func hurt(value: float):
	set_health(health - value)
