# This script is attached to the viewport on the player's speech texture.
# This is a tool scrpit, meaning that it gets executed in the editor.
tool
extends Viewport

# Every frame, resize this viewport to the label's size.
func _process(delta):
	size = $Label.rect_size
