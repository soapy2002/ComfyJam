class_name Interactable
extends Area3D

# Signals to notify the parent object when an interaction happens
signal interacted(player)

# Called by the player script when they press the interact key
func interact(player):
	interacted.emit(player)
	
func focus():
	pass

func unfocused():
	pass

func _physics_process(_delta):
	# Checks if the engine detects ANY Area3D entering your zone this frame
	for area in get_overlapping_areas():
		print("DEBUG: My interactor is currently touching: ", area.name)
		print("DEBUG: Is it an Interactable class? -> ", area is Interactable)
