extends TileMapLayer

signal cells_changed

#the Obstacle tilemap source ID (found in tilemaps window)
var tile_source_id: int = 0
#the exact spot in which the tile is in the tileset. (Can also be checked in the tilemaps window)
var tile_atlas_coords: Vector2i = Vector2i(0,0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("build"):
		var mouse_pos = get_global_mouse_position()
		var local_pos = local_to_map(mouse_pos)
		
		set_cell(local_pos, 0, tile_atlas_coords)

# according to https://github.com/godotengine/godot/issues/107342
# the changed signal is not emitted when set_cell is called.
# this is a workaround
func _update_cells(_coords: Array[Vector2i], _forced_clean: bool) -> void:
	cells_changed.emit()
