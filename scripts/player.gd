extends CharacterBody3D

signal coin_collected

#@export_subgroup("Components")
@onready var view: Node3D = $"../View"
@onready var camera: Node3D = view.get_node_or_null("Camera")

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7

@export var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var previously_floored = false

var jump_single = true
var jump_double = true

var coins = 0

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var model = $Character
@onready var collider = $Collider
@onready var animation = $Character/AnimationPlayer

@export var vehicle : Node3D
var current_area: Area3D = null

func _enter_tree() -> void:
	set_multiplayer_authority(str(get_parent_node_3d().name).to_int())

func _ready() -> void:
	if not is_multiplayer_authority(): return
	camera.current = true

func _physics_process(delta):
	if not is_multiplayer_authority(): return

	handle_controls(delta)
	handle_gravity(delta)
	handle_effects(delta)

	var applied_velocity: Vector3
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity

	velocity = applied_velocity

	if !view.aiming:
		if Vector2(velocity.z, velocity.x).length() > 0:
			rotation_direction = Vector2(velocity.z, velocity.x).angle()
	else:
		var camera_forward = -view.global_transform.basis.z.normalized()
		rotation_direction = atan2(camera_forward.x, camera_forward.z)
	
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)

	if position.y < -10:
		get_tree().reload_current_scene()

	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)

	if is_on_floor() and gravity > 2 and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
		Audio.play("res://sounds/land.ogg")

	previously_floored = is_on_floor()
	move_and_slide()
	

func handle_effects(delta):
	particles_trail.emitting = false
	sound_footsteps.stream_paused = true

	if is_on_floor():
		var horizontal_velocity = Vector2(velocity.x, velocity.z)
		var speed_factor = horizontal_velocity.length() / movement_speed / delta
		if speed_factor > 0.05:
			if animation.current_animation != "walk":
				animation.play("walk", 0.1)

			if speed_factor > 0.3:
				sound_footsteps.stream_paused = false
				sound_footsteps.pitch_scale = speed_factor

			if speed_factor > 0.75:
				particles_trail.emitting = true

		elif animation.current_animation != "idle":
			animation.play("idle", 0.1)
	elif animation.current_animation != "jump":
		animation.play("jump", 0.1)

func handle_controls(delta):
	if not is_multiplayer_authority(): return
	if vehicle != null:
		global_transform.origin = vehicle.global_transform.origin
		if Input.is_action_just_pressed("select"):
			get_out_of_vehicle()
		return
	
	var input := Vector3.ZERO

	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	if view.aiming:
		input = -input.rotated(Vector3.UP, rotation.y)
	else:
		input = input.rotated(Vector3.UP, view.rotation.y)
		
	if input.length() > 1:
		input = input.normalized()

	movement_velocity = input * movement_speed * delta
	if Input.is_action_pressed("sprint"):
		movement_velocity *= 1.75
	
	if Input.is_action_just_pressed("select") and current_area != null:
		get_into_vehicle()

	if Input.is_action_just_pressed("jump"):
		if jump_single or jump_double:
			jump()

func handle_gravity(delta):
	if not is_multiplayer_authority(): return
	if vehicle != null:
		return
	gravity += 25 * delta

	if gravity > 0 and is_on_floor():
		jump_single = true
		gravity = 0

func jump():
	Audio.play("res://sounds/jump.ogg")

	gravity = -jump_strength

	model.scale = Vector3(0.5, 1.5, 0.5)

	if jump_single:
		jump_single = false;
		jump_double = true;
	else:
		jump_double = false;

func collect_coin():
	coins += 1
	coin_collected.emit(coins)

func get_into_vehicle() -> void:
	hide()
	vehicle = current_area
	set_collision_layer_value(1, 0)
	$Area3D.monitoring = false
	sound_footsteps.playing = false
	
func get_out_of_vehicle() -> void:
	show()
	vehicle.get_parent_node_3d().deactivate()
	vehicle = null
	$Area3D.monitoring = true
	sound_footsteps.playing = true

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("selectable"):
		current_area = area
		area.select()

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("selectable"):
		current_area = null
		area.select()
