extends Node3D

@onready var outline = preload("res://objects/selected.gdshader")
@export var mesh_instance : MeshInstance3D
@export var object : Node3D

var outline_material : ShaderMaterial

@export var is_selected = false

func _ready() -> void:
	outline_material = ShaderMaterial.new()
	outline_material.shader = outline

func _process(delta: float) -> void:
	#if not is_multiplayer_authority(): return
	if is_selected and Input.is_action_just_pressed("select"):
		object.activate()
		print("get into car")

func select():
	is_selected = !is_selected
	if is_selected:
		apply_outline()
	else:
		remove_outline()
	
func apply_outline() -> void:
	if outline_material is ShaderMaterial:
		mesh_instance.mesh.surface_get_material(0).set_next_pass(outline_material)
	else:
		print("Error: Material is not a ShaderMaterial.")
	
	
func remove_outline() -> void:
	mesh_instance.mesh.surface_get_material(0).set_next_pass(null)
