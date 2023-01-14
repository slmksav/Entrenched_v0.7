extends Node

export(String, "res://World.tscn", "res://World/Test/MultiplayerTest.tscn") var world_select: String
export(PackedScene) var customizer

onready var loader: ResourceInteractiveLoader = ResourceLoader.load_interactive(world_select)


func go():
	set_process(true)


func _ready():
	set_process(false)


func _process(delta: float):
	var error: int = loader.poll()
	match error:
		OK:
			$botleft/loading.value = math.percent(loader.get_stage(),loader.get_stage_count())
		ERR_FILE_EOF:
			
			var toworld: int = get_tree().change_scene_to(loader.get_resource())
			if toworld != OK:
				globals.iprint(["error getting to the world,",toworld])
		_:
			globals.iprint(["error loading the scene %s" % error])


func singlepressed():
	go()

func _on_customize_pressed():
	get_tree().change_scene_to(customizer)
