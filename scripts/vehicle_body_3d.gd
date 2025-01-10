extends VehicleBody3D

@export var max_steering = 0.3
@export var engine_power = 100
@export var is_active = false
@export var driver_node : Node3D = null
@onready var state = $State

var max_rpm = 500
var max_torque = 100

func _process(delta: float) -> void:
	if driver_node != null:
		state.sync_driver_node = driver_node
		state.sync_position = global_position
		state.sync_rotation = global_rotation
	if Input.is_action_just_pressed("debug"):
		print("Is Active: " + str(is_active))
		print("Driver: " + str(driver_node))
	
func _physics_process(delta: float) -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		global_position = state.sync_position
		global_rotation = state.sync_rotation
		driver_node = state.sync_driver_node
		return
	if driver_node == null: return
	handle_driving(delta)
	
func handle_driving(delta: float) -> void:
	if driver_node == null:
		steering = 0
		$"wheel-bl".engine_force = 0
		$"wheel-br".engine_force = 0
		return
	steering = move_toward(steering, Input.get_axis("move_right", "move_left") * max_steering, delta * 5)
	var acceleration = Input.get_axis("move_back", "move_forward")
	print(str(is_active) + " Steering = " + str(steering) + " Accl = " + str(acceleration))
	var rpm = $"wheel-bl".get_rpm()
	$"wheel-bl".engine_force = acceleration * max_torque * (1 - rpm / max_rpm)
	rpm = $"wheel-br".get_rpm()
	$"wheel-br".engine_force = acceleration * max_torque * (1 - rpm / max_rpm)

func set_driver(driver: Node3D):
	print("Set driver on " + str(multiplayer.get_unique_id()))
	driver_node = driver
