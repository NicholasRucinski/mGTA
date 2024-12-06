extends VehicleBody3D

@export var max_steering = 0.3
@export var engine_power = 100

var max_rpm = 500
var max_torque = 100
var is_active = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("select") and is_active:
		deactivate()
	
func _physics_process(delta: float) -> void:
	if !is_active:
		return
	steering = move_toward(steering, Input.get_axis("move_right", "move_left") * max_steering, delta * 5)
	var acceleration = Input.get_axis("move_back", "move_forward")
	var rpm = $"wheel-bl".get_rpm()
	$"wheel-bl".engine_force = acceleration * max_torque * (1 - rpm / max_rpm)
	rpm = $"wheel-br".get_rpm()
	$"wheel-br".engine_force = acceleration * max_torque * (1 - rpm / max_rpm)
	
	


func activate() -> void:
	is_active = !is_active
	
func deactivate() -> void:
	is_active = false
