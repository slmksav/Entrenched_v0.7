extends VBoxContainer

onready var lighter=$eyelight/clip/lightpic
export(NodePath) var tovisual
onready var visual=get_node(tovisual)
#color is passed by value, so we change lighter.color.
func _on_lightpic_color_changed(_color):
	lighter.color.v=clamp(lighter.color.v,0,0.6)
	lighter.color.h=$eyecolors/switcher.selected.get_node("ColorRect").color.h
	visual.get_node("chest").eyecolor(lighter.color)
	visualprefs.preferences["eyecolor"]=lighter.color.to_html(false)
func setcolor(button):
	lighter.color=button.get_node("ColorRect").color
