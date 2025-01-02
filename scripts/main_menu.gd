extends Control

@onready var name_text_field = $MarginContainer/HBoxContainer/VBoxContainer/TextEdit

func on_start_server_pressed() -> void:
	Game.enet_peer.create_server(Game.PORT)
	multiplayer.multiplayer_peer = Game.enet_peer
	multiplayer.peer_connected.connect(Game.spawn_player)
	multiplayer.peer_disconnected.connect(Game.remove_player)
	
	Game.upnp_setup()
	
	Game.load_map()
	Game.spawn_player(multiplayer.get_unique_id())
	
func on_start_client_pressed() -> void:
	Game.enet_peer.create_client("localhost", Game.PORT)
	multiplayer.multiplayer_peer = Game.enet_peer
	Game.load_map()
