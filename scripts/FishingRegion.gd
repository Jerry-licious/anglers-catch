# A fishing region is an area where the player can get stuff. Each area has its
# own item pool, where the player can randomly get something upon catch.
# Edit the collision shape of the area to change the shape and size of the 
# fishing region.
extends Area

# The item pool consists of a list of fishing items.
export(Array, Resource) var item_pool

# Another RNG.
var rng = RandomNumberGenerator.new()


func _ready():
	# Make the random random.
	rng.randomize()


# Gets a random item and removes it from the pool.
func get_item() -> FishingItem:
	# Randomly pick an item.
	var item: FishingItem = item_pool[rng.randi_range(0, item_pool.size() - 1)]
	
	# Remove the item from the pool if it can only be fished up once.
	if item.exhaustable:
		item_pool.erase(item)
	
	# Remove this fishing area if there's no more fish left.
	if item_pool.empty():
		queue_free()
	
	return item
