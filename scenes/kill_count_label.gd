extends Label

var kills = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for zombie in get_tree().get_nodes_in_group("ZombieGroup"):
		zombie.ready.connect(_connect_zombie_kill_counter.bind(zombie))

func _connect_zombie_kill_counter(zombie: Node2D):
	zombie.health_system.zero_health.connect(_on_zombie_kill)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_zombie_kill() -> void:
	kills += 1
	text = "Kills: %s" % kills
