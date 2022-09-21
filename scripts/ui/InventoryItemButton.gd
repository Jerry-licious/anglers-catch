tool
extends Button

# Called when the button is clicked. Also passes the fishing item itself to make
# things easier.
signal examine(item)

# The button has an item that it will display.
# THIS HAS TO BE AN INSTANCE OF FISHINGITEM.
export(Resource) var item

# Called when the node enters the scene tree for the first time.
func _ready():
	# If there is a fishing item.
	if item != null:
		icon = item.image

func _on_clicked():
	emit_signal("examine", item)
