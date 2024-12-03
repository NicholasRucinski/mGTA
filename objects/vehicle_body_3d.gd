extends VehicleBody3D

var is_active = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("select") and is_active:
		deactivate()
	
func _physics_process(delta: float) -> void:
	if !is_active:
		return
	steering = Input.get_axis("move_right", "move_left") * 0.4
	engine_force = Input.get_axis("move_back", "move_forward") * 100


func activate() -> void:
	is_active = true
	
func deactivate() -> void:
	is_active = false
