extends Control

signal open_inventory

func _on_inventory_button_pressed():
	emit_signal("open_inventory")
