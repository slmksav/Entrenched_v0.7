extends ProgressBar
func _ready():
	visible=false
	value=100


func _on_playerrep_updated_health(new_health):
	value=new_health
	visible=true
	globals.iprint(new_health)
