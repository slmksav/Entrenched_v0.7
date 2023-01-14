extends Area2D

export(String, FILE, "*.tscn") var target_scene
export var spawn_position:Vector2

func _on_Door_body_entered(body: Node) -> void:
	body.get_parent().remove_child(body)
	SceneManager.player = body
	SceneManager.enter_scene(target_scene, spawn_position)
