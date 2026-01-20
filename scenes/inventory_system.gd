extends Node
class_name InventorySystem 

@export var inventory = []
var selected_item



func _set_inventory(item: String):
	inventory.append(item)
	print(inventory)

func add_item(new_item: String):
	_set_inventory(new_item)
