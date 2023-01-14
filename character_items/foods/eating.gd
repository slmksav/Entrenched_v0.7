extends AnimationPlayer

export(int) var hunger_points
export(float, 0, 100) var cure_percentage
onready var player = globals.player
onready var hotbar = $"/root/GlobalWorld/world/player/UI/bottom/list"

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		# Hold mouse down
		if event.is_pressed() and current_animation != "eat":
			play("eat")
		# Cancel eating
		elif not event.is_pressed() and current_animation != "idle":
			play("idle")

func _on_animator_animation_finished(anim_name):
	if anim_name == "eat":
		play("idle")
		hotbar.selected.item.parentinventory.delete_item(hotbar.selected.item.index,1)
		var tween = player.hungerBar.get_node("Tween")
		tween.stop(player.hungerBar)
		player.hunger += hunger_points
		if player.infected and player.sick < 80:
			var cure = rand_range(0, 100)
			if cure <= cure_percentage:
				player.recovering = true
		if player.hunger > 100:
			player.hunger = 100
		player.start_hunger()
