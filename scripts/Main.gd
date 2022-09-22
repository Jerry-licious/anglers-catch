extends Spatial


func _on_overlay_open_inventory():
	$CanvasLayer/Inventory.refresh()
	$CanvasLayer/Inventory.show()
