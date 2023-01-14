extends VBoxContainer

export(NodePath) onready var visual=get_node(visual)
func _on_switcher_selected(button):
	visual.player_cosmetics["monocle"]=button.name=="monocle"
