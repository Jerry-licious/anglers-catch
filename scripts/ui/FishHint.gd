extends PanelContainer

func _process(delta):
	if Input.is_action_pressed("fish"):
		queue_free()
