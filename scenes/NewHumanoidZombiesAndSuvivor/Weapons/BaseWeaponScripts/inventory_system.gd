extends Node
class_name InventorySystem 

@export var inventory = []
var selected_item



func _set_inventory(item: Weapon):
	inventory.append(item)
	print(inventory)

func add_item(new_item: Weapon):
	_set_inventory(new_item)
