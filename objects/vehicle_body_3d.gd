extends VehicleBody3D

@export var max_steering = 0.3
@export var engine_power = 100

var max_rpm = 500
var max_torque = 100
@export var is_active = false

func _process(delta: float) -> void:
	#if not is_multiplayer_authority(): return
	if Input.is_action_just_pressed("select") and is_active:
		rpc("deactivate")
	
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	if !is_active:
		steering = 0
		$"wheel-bl".engine_force = 0
		$"wheel-br".engine_force = 0
		return
	steering = move_toward(steering, Input.get_axis("move_right", "move_left") * max_steering, delta * 5)
	var acceleration = Input.get_axis("move_back", "move_forward")
	var rpm = $"wheel-bl".get_rpm()
	$"wheel-bl".engine_force = acceleration * max_torque * (1 - rpm / max_rpm)
	rpm = $"wheel-br".get_rpm()
	$"wheel-br".engine_force = acceleration * max_torque * (1 - rpm / max_rpm)

@rpc("any_peer")
func activate() -> void:
	print("activate\n")
	is_active = true
	print(str(multiplayer.get_unique_id()) + ": " + str(is_active))

@rpc("any_peer")
func deactivate() -> void:
	is_active = false
	print(str(multiplayer.get_unique_id()) + ": " + str(is_active))
	steering = 0
	$"wheel-bl".engine_force = 0
	$"wheel-br".engine_force = 0
