# The fishing item is a kind of resource that can be loaded and referenced anywhere.
# This means that we're allowed to create files of these resources and be able
# to mass produce items instead of having to hard-code every one of them.
extends Resource
# Scripts in Godot are classes, and classes by default are attached to their node.
# This one is special, we'll give it a name so we can refer to it elsewhere in 
# the engine.
class_name FishingItem

# Export means that this field can be edited in the inspector.
# We'll have a few fields for our objects, these should be pretty self explanatory.
export(String) var name
export(Texture) var image
export(String) var description
export(Array, String) var examination_quotes
# If this item can be fished up without removing it from the pool that 
# it belongs to.
export(bool) var exhaustable

# The number of times that the player has obtained this item.
var times_caught: int = 1

# Make a random number generator that allows us to pick random examination quotes.
var rng = RandomNumberGenerator.new()


# The init function is called when the resource is first created in the engine.
# Let's add some default values to make sure that the game doesn't get caught 
# off guard with missing fields and crash.
func _init(p_name = "UNNAMED OBJECT", \
		p_image = load("icon.png"), \
		p_description = "NO DESCRIPTION", \
		p_examination_quotes = [], \
		p_exhaustable = false):
	# We'll assign the initial values to the object here.
	name = p_name
	image = p_image
	description = p_description
	examination_quotes = p_examination_quotes
	exhaustable = p_exhaustable
	
	# By default, random number generators start with the same seed. To make
	# it unique, we'll randomise the randomiser.
	rng.randomize()


func has_examination_quote() -> bool:
	return examination_quotes.size() > 0

func get_random_examination_quote() -> String:
	return examination_quotes[rng.randi_range(0, examination_quotes.size() - 1)]
