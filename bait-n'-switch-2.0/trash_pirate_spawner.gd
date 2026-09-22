extends Marker3D

@export var trash_pirate: PackedScene = preload("res://NPCS/TrashPriate.tscn")
@export_range(0, 23) var spawn_hour: int = 7 # Hour of Day npc spawns.
@export_range(0,23) var despawn_hour: int = 8 # Hour of Day npc despawns.
var skibidi_six_seven: Node = null 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameTimeTracker.time_of_day_changed.connect(_on_hour_changed)
	
func _on_hour_changed(current_hour: int) -> void:
	if current_hour == spawn_hour:
		spawn_npc()
		print_debug("Trash_spawn")
	elif current_hour == despawn_hour:
		despawn_npc()

func spawn_npc() -> void:
	if is_instance_valid(skibidi_six_seven):
		return
	
	if not trash_pirate:
		push_warning("spawner: No NPC assigned.")
		return
	
	skibidi_six_seven = trash_pirate.instantiate()
	get_tree().current_scene.add_child(skibidi_six_seven)
	skibidi_six_seven.global_position = global_position
	
func despawn_npc() -> void:
	if is_instance_valid(skibidi_six_seven):
		skibidi_six_seven.queue_free()

func _check_initial_spawn() -> void:
	var current = GameTimeTracker.current_hour
	var rizz_modifier = false
	
	if spawn_hour > despawn_hour:
		rizz_modifier = current >= spawn_hour or current < despawn_hour
	else:
		rizz_modifier = current >= spawn_hour and current < despawn_hour
	
	if rizz_modifier:
		spawn_npc()
