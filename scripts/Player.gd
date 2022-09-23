# The player is a rigid body, meaning that the game does the mathing for us 
# so we don't have to.
extends RigidBody

# All possible speeches of the player are contained in this resource.
# MAKE SURE THAT IT'S AN INSTANCE OF PLAYERQUOTES.
export(Resource) var quotes

# The player emits a catch signal when they catch a fish.
signal catch(item)

# The strength of the movement vector. 
# This determines how fast the boat accelerates.
const movement_strength = 0.1
# How long the character speaks for, in seconds.
const speech_time = 1.8

# Record the player's fishing state to check what they are/aren't allowed to do.
enum FishingState { IDLE, CASTING, FISHING }
var fishing_state = FishingState.IDLE

# Tracks if the player is already speaking.
var speaking = false

# Have an RNG to keep track of fishing stuff.
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	# Godot's RNGs have the same seed, use randomise upon initialisation to make
	# sure that it's actually random.
	rng.randomize()


func _process(delta):
	# The fishing mechanic has been placed in a separate block of code to make
	# all of this look cleaner.
	update_fishing_mechanic()
	
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
	
	# Only allow the player to move when the player isn't fishing.
	if fishing_state == FishingState.IDLE:
		# Since we are a rigid body, the game allows us to apply a force (acceleration)
		# to our boat and move it according to the player's control.
		apply_central_impulse(movement_vector.rotated(Vector3(0, 1, 0), ry) * movement_strength)
	else:
		# If the player is trying to move while they couldn't.
		if movement_vector.length() > 0:
			speak(quotes.cannot_move_because_player_is_fishing)
			# Set movement to 0 so the player's animation doesn't update.
			movement_vector = Vector3.ZERO
	
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


# Makes the player talk by changing the viewport label.
func speak(text: String):
	# Only speak if the character isn't already speaking.
	if not speaking:
		$Speech.text = text
		speaking = true
		
		# Wait for a bit before having the speech disappear.
		yield(get_tree().create_timer(speech_time), "timeout")
		
		# Once speaking is finished, clear the text and reset the speaking state.
		$Speech.text = ""
		speaking = false


# When integrating forces,
func _integrate_forces(state):
	# Remove any angular velocity
	# So the boat doesn't start spinning.
	state.angular_velocity = Vector3.ZERO


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


# The chance that the water will begin to bubble to indicate a potential catch
# every tick.
const bubble_chance = 0.005
# Each time it bubbles, there's only a chance that you can catch the fish.
const bubble_catch_chance = 0.5

# The total duration of one bubble animation, in seconds.
var bubbling_animation_duration = 3.0
var bubbling = false
# The starting time of the current bubbling animation, in MILLIseconds.
var bubbling_time_start = 0

var can_catch = false
var fake_bubbling_intensity = 0.4

# The fishing mechanic has been placed in a separate block of code to make
# all of this look cleaner.
func update_fishing_mechanic():
	# Track how long it's been bubbling.
	var time_since_bubbling = Time.get_ticks_msec() - bubbling_time_start
	# The intensity maxes out in the middle.
	var bubble_animation_duration = bubbling_animation_duration * 1000.0
	var bubbling_progress = time_since_bubbling / bubble_animation_duration
	var bubbling_intensity = 1 - abs(bubbling_progress - 0.5)
	
	# If the player uses the fish button.
	if Input.is_action_just_pressed("fish"):
		# If they're not currently fishing.
		if fishing_state == FishingState.IDLE:
			# We only allow the player to fish if they aren't moving.
			# This nested if is deliberate to make things look cleaner.
			if linear_velocity.length() < 0.1:
				# Start playing the animation and update the fishing state.
				fishing_state = FishingState.CASTING
				$Layers/Character.set_animation("casting")
				# Actually start playing the animation.
				$Layers/Character.playing = true
			else:
				# If the player isn't allowed to fish, we'll have some way to tell the
				# player to stop moving.
				speak(quotes.cannot_fish_because_player_is_moving)
		elif fishing_state == FishingState.FISHING:
			# If we're in a sweetspot, the fish can be caught.
			if can_catch:
				if bubbling:
					if bubbling_progress > 0.25 and bubbling_progress < 0.75:
						emit_signal("catch", get_fish())
					else:
						speak(quotes.missed_fish)
				else:
					speak(quotes.premature_pull)
			# Reset bubbling status.
			bubbling = false
			$Layers/Bubbles.opacity = 0
			# Reset fishing status.
			fishing_state = FishingState.IDLE
			$Layers/Character.set_animation("default")
	
	# If the player is currently fishing, and there's no bubbling animation 
	# going on.
	if fishing_state == FishingState.FISHING and not bubbling:
		# Every tick, there's a small chance that the fish would start bubbling.
		if rng.randf() < bubble_chance:
			if can_fish():
				bubbling = true
				# Track down when the bubbling started so we can calculate the animations.
				bubbling_time_start = Time.get_ticks_msec()
				
				can_catch = rng.randf() < bubble_catch_chance
			else:
				speak(quotes.no_fish)
	
	# If we're currently bubbling.
	if bubbling:
		# Update the opacity of the bubbles based on our intensity.
		$Layers/Bubbles.opacity = bubbling_intensity
		
		# The player can detect early in the bubbling if it's time to catch.
		if bubbling_progress > 0.25 and bubbling_progress < 0.3\
				 and rng.randf() < 0.1:
			if can_catch:
				speak(quotes.hooked)
			else:
				speak(quotes.not_hooked)
		
		
		if not can_catch:
			# Dim the opacity by a bit if this isn't a real catch.
			$Layers/Bubbles.opacity *= fake_bubbling_intensity
		
		
		# If the bubbling time has ran out, turn it off.
		if (time_since_bubbling > bubbling_animation_duration * 1000):
			bubbling = false
			# Make sure that this is exactly 0.
			$Layers/Bubbles.opacity = 0


# This area has the same hitbox as the player, if it overlaps with a given
# fishing area, you can fish from there.
onready var fishing_detect: Area = $FishingDetect


# Determines if the player is actually next to another fishing area and can 
# hook anything up.
func can_fish() -> bool:
	for area in fishing_detect.get_overlapping_areas():
		# Just in case the overlapping area isn't a fishing area.
		if area.has_method("get_item"):
			return true
	return false


# Draws an item from the current fishing area.
func get_fish() -> FishingItem:
	for area in fishing_detect.get_overlapping_areas():
		# Just in case the overlapping area isn't a fishing area.
		if area.has_method("get_item"):
			return area.get_item()
	# This shouldn't happen.
	return null


func _examine_fish(item: FishingItem):
	if item.has_examination_quote():
		speak(item.get_random_examination_quote())
