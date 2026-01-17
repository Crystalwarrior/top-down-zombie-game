extends TileMapLayer

@onready var obstacles: TileMapLayer = $"../Obstacles"

func _ready() -> void:
	obstacles.cells_changed.connect(_on_obstacles_changed)

func _on_obstacles_changed() -> void:
	notify_runtime_tile_data_update()

# Called when the node enters the scene tree for the first time.
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if coords in obstacles.get_used_cells_by_id(0):
		return true
	return false

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if coords in obstacles.get_used_cells_by_id(0):
		tile_data.set_navigation_polygon(0 , null)
