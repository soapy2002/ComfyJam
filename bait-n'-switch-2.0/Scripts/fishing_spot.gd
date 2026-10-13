extends Node3D

@onready var interactable = $Interactable

func _ready():
	interactable.interacted.connect(_on_interacted)

func _on_interacted(player):
	if player.has_method("start_fishing"):
		player.start_fishing(global_position) 
