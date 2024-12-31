extends Node3D

@export_group("Properties")
@export var target: Node

@export_group("Zoom")
@export var zoom_minimum = 16
@export var zoom_maximum = 4
@export var zoom_speed = 1

@export_group("Rotation")
@export var rotation_speed = 0.5
@export var horizontal_sensitivity = 0.2
@export var vertical_sensitivity = 0.2

var camera_rotation:Vector3
var zoom = 10
var aiming = false

@onready var camera: Camera3D = $Camera

func _enter_tree() -> void:
	set_multiplayer_authority(str(get_parent_node_3d().name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_rotation = rotation_degrees # Initial rotation

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	self.position = self.position.lerp(target.position, delta * 4)
	rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 6)
	
	if not aiming:
		camera.position = camera.position.lerp(Vector3(0, 0, zoom), 8 * delta)

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	var input := Vector3.ZERO
	
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(2):
			aiming = true
			camera = $"Camera3D"
			camera.current = true
		else:
			aiming = false
			camera = $Camera
			camera.current = true
	
	if event is InputEventMouseMotion:
		input.x = -event.relative.y * vertical_sensitivity
		input.y = -event.relative.x * horizontal_sensitivity
		
		camera_rotation += input * rotation_speed
		camera_rotation.x = clamp(camera_rotation.x, -70, 0)
		
	zoom += Input.get_axis("zoom_in", "zoom_out") * zoom_speed
	zoom = clamp(zoom, zoom_maximum, zoom_minimum)
