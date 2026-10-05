class_name Interactor
extends Area3D

@export var player_node: Node3D # Reference to the main player script

var active_interactable: Interactable = null

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _unhandled_input(event):
	if event.is_action_pressed("Interact") and active_interactable:
		active_interactable.interact(player_node)

func _on_area_entered(area: Area3D):
	if area is Interactable:
		if active_interactable: 
			active_interactable.unfocused()
		active_interactable = area
		active_interactable.focus()

func _on_area_exited(area: Area3D):
	if area == active_interactable:
		active_interactable.unfocused()
		active_interactable = null
