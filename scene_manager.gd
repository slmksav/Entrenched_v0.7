extends Node

var player:Node2D

func enter_scene(new_scene:String, spawn_pos:Vector2):
	get_tree().change_scene(new_scene)
	yield(get_tree(), "idle_frame")
	var existing_players = get_tree().get_nodes_in_group("player")
	for node in existing_players:
		node.queue_free()
	get_tree().current_scene.add_child(player)
	player.global_position = spawn_pos
