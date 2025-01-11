extends VehicleBody3D

@export var max_steering = 0.3
@export var engine_power = 100
@export var driver_node : Node3D = null

var steering_input: float = 0.0
var acceleration: float = 0.0

var max_rpm = 500
var max_torque = 100

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		print("Driver: " + str(driver_node))
	
func _physics_process(delta: float) -> void:
	handle_driving(delta)
	
func handle_driving(delta: float) -> void:
	#if driver_node == null:
		#steering = 0
		#engine_force = 0
		#$"wheel-bl".engine_force = 0
		#$"wheel-br".engine_force = 0
		#return
	steering = move_toward(steering, steering_input * max_steering, delta * 5)
	var rpm = $"wheel-bl".get_rpm()
	$"wheel-bl".engine_force = acceleration * max_torque * (1 - rpm / max_rpm)
	rpm = $"wheel-br".get_rpm()
	$"wheel-br".engine_force = acceleration * max_torque * (1 - rpm / max_rpm)

func set_driver(driver: Node3D):
	if driver == null: return
	$Input.set_multiplayer_authority(driver.multiplayer.get_unique_id(), true)
	print("id " + str(driver.multiplayer.get_unique_id()))
	if not is_multiplayer_authority(): return
	print("Set driver on " + str(multiplayer.get_unique_id()))
	driver_node = driver

func _on_input_new_input(steer_input: float, accel: float) -> void:
	steering_input = steering_input
	acceleration = accel
