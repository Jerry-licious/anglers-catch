# The player is a rigid body, meaning that the game does the mathing for us 
# so we don't have to.
extends RigidBody

# The strength of the movement vector. 
# This determines how fast the boat accelerates.
const movement_strength = 0.05

# Record the player's fishing state to check what they are/aren't allowed to do.
enum FishingState { IDLE, CASTING, FISHING }
var fishing_state = FishingState.IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	# If the player fishes, start playing the animation.
	if Input.is_action_just_pressed("fish") and fishing_state == FishingState.IDLE:
		
		fishing_state = FishingState.CASTING
		$Layers/Character.set_animation("casting")
		# Actually start playing the animation.
		$Layers/Character.playing = true
	
	# This vector provides a direction that our character moves in.
	# However, our player has been rotated by a bit to make the perspective look
	# less boring. This means that our movement vector should be adjusted accordingly
	# that is, to conform to the direction that the *player* rather than the
	# game engine thinks.
	# To make this easier (and allow us to change camera angles), I will calculate
	# the player's rotation on the spot.
	# Simply obtain the current rotation vector and get the y component.
	# Then, we'll apply that rotation to our movement vector, with the y axis 
	# as reference.
	var ry = rotation.y
	var movement_vector = Vector3(
		# Left/right
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0, # Up/down motion never happens since this is a 2d game disguised in 3d.
		Input.get_action_strength("move_back") - Input.get_action_strength("move_front")
	)
	
	# Control the animation of our boat based on if the player is moving/accelerating.
	if movement_vector.length() > 0:
		$Layers/Front.playing = true
		
		# Flip all the sprites according to if the player is moving left or right.
		if movement_vector.x > 0:
			# Use a scale vector to invert the direction of all the sprites so
			# we don't have to do them one by one!
			$Layers.scale = Vector3(1, 1, 1)
		elif movement_vector.x < 0:
			$Layers.scale = Vector3(-1, 1, 1)
	else:
		# If the player isn't accelerating, we will pause the animation on the boat.
		$Layers/Front.playing = false
	
	# Water splashes are more visible the faster the player is moving.
	$Layers/Splashes.opacity = linear_velocity.length() / 5
	
	# Since we are a rigid body, the game allows us to apply a force (acceleration)
	# to our boat and move it according to the player's control.
	apply_central_impulse(movement_vector.rotated(Vector3(0, 1, 0), ry) * movement_strength)
	

# This function is binded to the character, it gets called when any animation on
# the character is finished.
func _on_character_animation_finished():
	# If the fishing state is casting, the completion of the animation would mean
	# that the casting animation is finished.
	# This allows us to switch to the fishing animation and update our fishing
	# state accordingly.
	if fishing_state == FishingState.CASTING:
		fishing_state = FishingState.FISHING
		$Layers/Character.set_animation("fishing")
