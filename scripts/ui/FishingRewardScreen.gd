extends Control

# The fishing item that the screen represents.
# THIS HAS TO BE AN INSTANCE OF FISHINGITEM.
export(Resource) var fishing_item

onready var fish_image = $VBoxContainer/HBoxContainer/FishImage/CenterContainer/Fish
onready var fish_name = $VBoxContainer/HBoxContainer/FishText/CenterContainer2/VBoxContainer/NameBackground/Name
onready var fish_description = $VBoxContainer/HBoxContainer/FishText/CenterContainer2/VBoxContainer/DescriptionBackground/Description


func _ready():
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
