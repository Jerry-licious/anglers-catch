extends Spatial


func _on_overlay_open_inventory():
	$CanvasLayer/Inventory.refresh()
	$CanvasLayer/Inventory.show()
	pass # Replace with function body.
