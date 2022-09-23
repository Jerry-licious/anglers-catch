# Use the tool keyword to have this script work in the inspector.
tool
extends Control

# Sends a signal when the player dismisses an item so the character can speak.
signal dismiss(item)

# The fishing item that the screen represents.
# THIS HAS TO BE AN INSTANCE OF FISHINGITEM.
export(Resource) var fishing_item

onready var fish_image = $Fish
onready var fish_name = $Name
onready var fish_description = $Description

var last_opened_time: int = 0


func _ready():
	hide()
	# If the fishing item isn't null, display it.
	if not fishing_item == null:
		load_fishing_item(fishing_item)


# Loads in a specific fishing item.
func load_fishing_item(item):
	fish_name.text = item.name
	fish_description.text = item.description
	fish_image.texture = item.image


# This is called when the dismiss button is called.
func _dismiss_menu():
	hide()
	get_tree().paused = false
	emit_signal("dismiss", fishing_item)


# Connected to the signal when the player catches a fish.
func _on_catch(item):
	fishing_item = item
	
	load_fishing_item(item)
	show()
	get_tree().paused = true
