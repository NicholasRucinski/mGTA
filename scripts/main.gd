extends Node

const PORT : int = 8888
var enet_peer = ENetMultiplayerPeer.new()

@onready var main : Node = get_tree().root.get_node("Main")
@onready var players : Node = main.get_node("Players")

var Player = preload("res://objects/player.tscn")
var menu : Control = null
var map : Node = null

func _ready() -> void:
	menu = preload("res://scenes/main_menu.tscn").instantiate()
	main.add_child(menu)
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
func spawn_player(id: int):
	var player_name = "Testing"
	var player = Player.instantiate()
	player.name = str(id)
	player.get_node_or_null("PlayerController").player_name = player_name
	players.add_child(player, true)
	
func remove_player(id: int):
	var player = get_node_or_null(str(id))
	if player:
		player.queue_free()
	
func load_map():
	if map != null:
		map.queue_free()
	if menu != null:
		menu.queue_free()
		menu = null
		
	map = preload("res://scenes/city.tscn").instantiate()
	main.add_child(map)
	
func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
