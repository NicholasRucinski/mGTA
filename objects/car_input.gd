extends Node

signal new_input(steer_input: float, accel: float)

@export var steering_input: float = 0.0
@export var acceleration: float = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event.is_action("move_right") or event.is_action("move_left"):
		steering_input = Input.get_axis("move_right", "move_left")
		print(steering_input)
	if event.is_action("move_back") or event.is_action("move_forward"):
		acceleration = Input.get_axis("move_back", "move_forward")
		print(acceleration)
	new_input.emit(steering_input, acceleration)
