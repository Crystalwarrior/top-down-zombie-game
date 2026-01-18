extends ProgressBar


@export var health_system: HealthSystem

var anim_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self_modulate = Color.GREEN
	max_value = health_system.max_health
	value = health_system.health
	health_system.changed.connect(_on_health_system_changed)


func _on_health_system_changed() -> void:
	if anim_tween:
		anim_tween.kill()
	anim_tween = create_tween().set_parallel(true)
	self_modulate = Color.WHITE
	anim_tween.tween_property(self, "self_modulate", Color.GREEN, 0.2)
	anim_tween.tween_property(self, "value", health_system.health, 0.1)
	max_value = health_system.max_health
