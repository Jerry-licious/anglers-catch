# This is also a resource, check FishingItem to see how resources work.
extends Resource
class_name PlayerQuotes

# This file represents things that the player says outside of examining
# random fishing drops.
export(String) var cannot_fish_because_player_is_moving
export(String) var cannot_move_because_player_is_fishing

# When the player pulls without the water bubbling.
export(String) var premature_pull
# When the player pulls while the water is bubbling.
export(String) var missed_fish
# When a fish is hooked and the player can catch it, only has a chance to
# be spoken.
export(String) var hooked
# When it's bubbling but no fish is hooked, only has a chance to be spoken.
export(String) var not_hooked
# When the player is fishing in somewhere that has nothing to be caught.
export(String) var no_fish
