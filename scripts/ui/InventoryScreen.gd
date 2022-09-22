# Tool script so it can be updated.
tool
extends Control

# This is the screen's inventory.
export(Resource) var inventory

# Where each item is placed.
onready var list = $Center/HBox/ListContainer/List
var ItemButton = preload("res://scenes/ui/InventoryItemButton.tscn")


func _ready():
	hide()
	if not inventory == null:
		refresh()


# Rebuilds the UI to an updated inventory.
func refresh():
	# Clean up all the things in the list first.
	for control in list.get_children():
		control.queue_free()
	
	# Then create new buttons for each item in the inventory.
	for item in inventory.items:
		var button = ItemButton.instance()
		button.item = item
		# Connect the button to our click handler.
		button.connect("examine", self, "on_examine_item")
		
		list.add_child(button)


func on_examine_item(item: FishingItem):
	print("called")
	display_item(item)


onready var image_node = $Center/HBox/ExamineContainer/VBox/Center/ImageContainer/Image
onready var name_label = $Center/HBox/ExamineContainer/VBox/NameContainer/Name
onready var description_label = $Center/HBox/ExamineContainer/VBox/DescriptionContainer/Description

func display_item(item: FishingItem):
	image_node.texture = item.image
	name_label.text = item.name
	description_label.text = item.description


# When the player catches a fish, add it to the inventory.
func _on_catch(item):
	inventory.add_item(item)
	refresh()
	get_tree().paused = true


func _on_close_button_pressed():
	hide()
	get_tree().paused = false
