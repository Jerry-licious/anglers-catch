extends RigidBody

# The strength of the movement vector.
const movement_strength = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	apply_central_impulse(Vector3(
		# Left/right
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0, # Up/down motion never happens since this is a 2d game disguised in 3d.
		Input.get_action_strength("move_back") - Input.get_action_strength("move_front")
	) * movement_strength)
