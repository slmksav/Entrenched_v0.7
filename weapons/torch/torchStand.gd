extends Area2D

onready var torch = $sprite
onready var hotbar = $"/root/GlobalWorld/world/player/UI/bottom/list"
var has_torch = false
export(Resource) var torch_item
export(Resource) var playerinv


func _ready():
	if $sprite.visible:
		$anim.play("light")
		$fire.play()

func _on_torchStand_body_entered(body):
	if body == globals.player:
		globals.player.torch_stand = self

func _on_torchStand_body_exited(body):
	if body == globals.player:
		globals.player.torch_stand = null

func _unhandled_input(event):
	if event.is_action_pressed("deploy") and globals.player.torch_stand == self:
		if not has_torch and hotbar.selected.item != null and hotbar.selected.item.name == "torch":
			torch.visible = true
			has_torch = true
			hotbar.selected.item.amount -= 1
			hotbar.selected.updatecounter()
			$fire.play()
		elif has_torch:
			torch.visible = false
			has_torch = false
			if hotbar.selected.item == null or hotbar.selected.item.name != "torch":
				playerinv.add_item(torch_item)
			elif hotbar.selected.item.name == "torch":
				hotbar.selected.item.amount += 1
				hotbar.selected.updatecounter()
			$fire.stop()
