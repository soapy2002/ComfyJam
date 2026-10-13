extends CharacterBody3D


const SPEED = 5.0
const ACCELERATION = 20.0
const FRICTION = 20.0
const JUMP_VELOCITY = 4.5
const ROTATION_SPEED = 6.0 # Lower the rotation to make turning wider
enum States { MOVE, DIALOGUE, FISHING }

var current_interactable: Area3D = null
var can_interact: bool = true
var current_state = States.MOVE
@onready var mesh := $MeshInstance3D
@onready var neck := $NeckSocket
@onready var camera := $NeckSocket/SpringArm3D/Camera3D
@onready var spring_arm := $NeckSocket/SpringArm3D
@onready var fishing_controller = $FishingController 


func _unhandled_input(event: InputEvent) -> void:
	if current_state == States.MOVE:
		if event is InputEventMouseButton:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				neck.rotate_y(-event.relative.x * 0.001)
				spring_arm.rotate_x(event.relative.y * 0.001)
				spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-30), deg_to_rad(60))
		elif event.is_action_pressed("Interact") and current_interactable != null:
			if current_interactable.has_method("Interact"):
				current_interactable.interact()

func _physics_process(delta: float) -> void:
	if current_state == States.FISHING:
		# Keep gravity running so you don't float mid-air while holding the rod
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			velocity.x = 0
			velocity.z = 0
			
		move_and_slide()
		return
		
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Right", "Left", "Backward", "Forward")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
	if direction.length() > 0:
		var target_angle = atan2(direction.x, direction.z)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, target_angle, ROTATION_SPEED * delta)
		var forward_vector = mesh.global_transform.basis.z
		
		velocity.x = move_toward(velocity.x, forward_vector.x * SPEED, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, forward_vector.z * SPEED, ACCELERATION * delta)

	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		velocity.z = move_toward(velocity.z, 0, FRICTION * delta)

	move_and_slide()

# Triggered automatically when player walks up to an object
func _on_interaction_detector_area_entered(area: Area3D) -> void:
	if area.has_method("Interact"):
		current_interactable = area

# Triggered automatically when player walks away from the object
func _on_interaction_detector_area_exited(area: Area3D) -> void:
	if area == current_interactable:
		current_interactable = null

func start_fishing(dock_position):
	current_state = States.FISHING
	velocity = Vector3.ZERO # Freeze player movement
	
	# Turn off the interactor during fishing so it doesnt reset
	if has_node("Interactor"):
		$Interactor.monitoring = false
		
	# Tell our fishing sub-script to start the Big the Cat mechanics
	fishing_controller.activate(dock_position)

func end_fishing():
	can_interact = false
	current_state = States.MOVE
	print("Returned to walking mode safely.")
	if has_node("Interactor"):
		$Interactor.monitoring = true
		# Turn the interactor back on now that fishing hath concluded and wh
	await get_tree().process_frame
	can_interact = true
