extends Node

# Sync Players Server with Client

# Server
remote func remote_sync_player_data_server(data: Dictionary):
	var sender: int = get_tree().get_rpc_sender_id()
	for k in data.keys():
		Multiplayer.players[str(sender)][k] = data[k]
	Multiplayer.rset("players", Multiplayer.players)
	rpc("remote_player_sync_success", sender)
	globals.world.spawn_new_client(Vector2.ZERO, sender)


# Client

remote func remote_player_sync_success(sender: int):
	if sender == Multiplayer.local_network_peer:
		globals.world.spawn_player(Vector2.ZERO, str(Multiplayer.local_network_peer))
		for k in Multiplayer.players.keys():
			if k == str(Multiplayer.local_network_peer): continue
			globals.world.spawn_new_client(Vector2.ZERO, int(k))
	else: globals.world.spawn_new_client(Vector2.ZERO, sender)
