extends PanelContainer

func _process(delta):
	if Input.is_action_pressed("move_back") or \
		Input.is_action_pressed("move_front") or \
		Input.is_action_pressed("move_left") or \
		Input.is_action_pressed("move_right"):
		queue_free()
