extends Resource

# An inventory contains a list of item.
# THIS MUST BE A LIST OF FISHINGITEMS.
export(Array, Resource) var items

# Items are identified by their name.
func has_item(new_item):
	for item in items:
		if item.name == new_item.name:
			return true
	return false

# Add an item to the inventory if it wasn't there.
func add_item(new_item):
	if not has_item(new_item):
		items.append(new_item)
