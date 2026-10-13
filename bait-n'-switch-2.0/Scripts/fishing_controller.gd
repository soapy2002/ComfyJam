extends Node3D

enum FishingPhase { INACTIVE, AIMING, CASTING, REELING }
var current_phase = FishingPhase.INACTIVE

@export var player: CharacterBody3D
@export var aim_speed: float = 5.0
@export var max_cast_distance: float = 12.0
@export var cast_radius: float = 2.5 # The area around the cast where fish can be caught

@onready var aim_marker = $AimMarker
@onready var fish_container = $FishSpawner

var dock_origin: Vector3 = Vector3.ZERO
var fish_pool: Array[Node3D] = []

func _ready():
	# Keep visual components completely hidden until fishing starts
	aim_marker.visible = false
	
func activate(start_position: Vector3):
	dock_origin = start_position
	aim_marker.global_position = start_position + Vector3(0, -0.5, 2.0) 
	aim_marker.visible = true
	current_phase = FishingPhase.AIMING
	print("AIMING - Move the target marker with WASD. Press F to cast!")

func _unhandled_input(event):
	if event.is_echo():
		return
	
	# Handle input strictly based on the CURRENT phase
	match current_phase:
		FishingPhase.AIMING:
			if event.is_action_pressed("Fish_Cast"): 
				get_viewport().set_input_as_handled() 
				start_casted_phase()
			
		FishingPhase.CASTING:
			if event.is_action_pressed("Interact"): 
				get_viewport().set_input_as_handled()
				# Calculate distances, award fish score, and exit
				evaluate_catch()
			
		FishingPhase.INACTIVE:
			pass

func _process(delta):
	if current_phase == FishingPhase.AIMING:
		handle_aiming(delta)

func handle_aiming(delta):
	var input_dir = Input.get_vector("Right", "Left", "Backward", "Forward")
	var move_vector = Vector3(input_dir.x, 0, input_dir.y) * aim_speed * delta
	
	aim_marker.global_position += move_vector
	
	# Clamp the marker so the player cannot cast infinitely out into the ocean void
	var distance = aim_marker.global_position.distance_to(dock_origin)
	if distance > max_cast_distance:
		var direction = (aim_marker.global_position - dock_origin).normalized()
		aim_marker.global_position = dock_origin + (direction * max_cast_distance)

	# Lock target coordinates and commit the cast line
	if Input.is_action_just_pressed("Fish_Cast"):
		start_casted_phase()

# Spawning Fish around the Cast
func start_casted_phase():
	current_phase = FishingPhase.CASTING
	print("Fish are gathering! Press 'Interact' at the peak overlap moment to haul!")
	# Spawn a small school of fish targets around the targeted bait ring location
	spawn_local_fish_school(randi_range(3, 6))

func spawn_local_fish_school(amount: int):
	# Clear out any old remaining fish from previous games
	clear_fish_pool()
	
	for i in range(amount):
		# Create a basic 3D node representation for each individual fish
		var fish = Node3D.new()
		var mesh = MeshInstance3D.new()
		mesh.mesh = CapsuleMesh.new() # Simple proxy asset capsule representing a fish body
		mesh.scale = Vector3(0.2, 0.2, 0.5)
		fish.add_child(mesh)
		fish_container.add_child(fish)
		
		# Place the fish randomly spread out inside the outer water boundaries
		var random_offset = Vector3(randf_range(-4, 4), 0, randf_range(-4, 4))
		fish.global_position = aim_marker.global_position + random_offset
		
		# Give the fish node custom properties using Godot metadata dictionaries
		fish.set_meta("speed", randf_range(1.5, 3.5))
		fish.set_meta("angle", randf_range(0, TAU))
		
		fish_pool.append(fish)

func _physics_process(delta):
	if current_phase != FishingPhase.CASTING:
		return
		
	for fish in fish_pool:
		if is_instance_valid(fish):
			var speed = fish.get_meta("speed")
			var angle = fish.get_meta("angle") + (speed * delta)
			fish.set_meta("angle", angle)
			
			var radius_offset = 1.5 + sin(angle * 2.0) * 0.8
			var target_pos = aim_marker.global_position + Vector3(cos(angle), 0, sin(angle)) * radius_offset
			fish.global_position = fish.global_position.move_toward(target_pos, speed * delta)
			
			if fish.global_position.distance_to(target_pos) > 0.05:
				fish.look_at(target_pos, Vector3.UP)

# Reeling in and Fish Maths :sunglasses_Emoji: :Onkey_Emoji:
func evaluate_catch():
	var caught_count = 0
	
	# Loop through each swimming fish and calculate its distance from the cast zone
	for fish in fish_pool:
		if is_instance_valid(fish):
			var dist = fish.global_position.distance_to(aim_marker.global_position)
			# If the fish is sitting directly inside the overlap range, add it to the count bucket
			if dist <= cast_radius:
				caught_count += 1
				
	print("REELED IN! You captured a total of ", caught_count, " fish simultaneously!")
	
	# Finish and release player back to standard walking states
	exit_fishing_loop()

func clear_fish_pool():
	for fish in fish_pool:
		if is_instance_valid(fish):
			fish.queue_free()
	fish_pool.clear()

func exit_fishing_loop():
	current_phase = FishingPhase.INACTIVE
	aim_marker.visible = false
	clear_fish_pool()
	
	# If the export node reference is lost, look up the node tree directly
	var actual_player = player if player != null else get_parent()
	
	if actual_player and actual_player.has_method("end_fishing"):
		actual_player.end_fishing()
	else:
		push_error("CRITICAL ERROR: FishingController cannot find the master script! Object is: ", actual_player)
		# Debug crap because im stupid
