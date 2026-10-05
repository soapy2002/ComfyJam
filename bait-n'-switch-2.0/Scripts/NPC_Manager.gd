extends CharacterBody3D
class_name NPC3D

enum Schedule { ALWAYS, DAY_ONLY, NIGHT_ONLY }

@export_group("Identity & State")
@export var npc_name: String = "Villager"
@export var schedule: Schedule = Schedule.ALWAYS

@export_group("Movement")
@export var speed: float = 3.0
#@export var wander_radius: float = 5.0  # If we want an npc that sort of just walks around an area lol

@onready var original_y: float = global_position.y
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	GameTimeTracker.time_of_day_changed.connect(_on_time_of_day_changed)
	# Makes sure the NPC starts with the correct visibility state
	_on_time_of_day_changed(GameTimeTracker.is_day)
	interactable.interacted.connect(_on_interact)

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	pass
	# Add pathfinding logic here at some point
	#move_and_slide() This doesnt work because script is not attached to character

func _on_interact(_player):
	print("Hey what's up man, it's a me Longo!")

func _on_time_of_day_changed(is_daytime: bool) -> void:
	var should_be_active: bool = true
	match schedule:
		Schedule.DAY_ONLY:
			visible = is_daytime
			should_be_active = is_daytime
			process_mode = PROCESS_MODE_INHERIT if is_daytime else PROCESS_MODE_DISABLED
		Schedule.NIGHT_ONLY:
			visible = !is_daytime
			should_be_active = !is_daytime
			process_mode = PROCESS_MODE_INHERIT if !is_daytime else PROCESS_MODE_DISABLED
		Schedule.ALWAYS:
			visible = true
			process_mode = PROCESS_MODE_INHERIT
			should_be_active = true
	
	visible = should_be_active 
	$CollisionShape3D.disabled = !should_be_active # Toggle Collision so invisible/inactive npcs dont block the player
	set_physics_process(should_be_active) # Stopping physics processing without stoping the script from recieving signals I hope (This didnt work like 5 times)
