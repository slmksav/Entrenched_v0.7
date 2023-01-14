extends MeshInstance2D

onready var vis: VisibilityNotifier2D = $VisibilityNotifier2D

func _ready():
	assert(mesh is QuadMesh or mesh is SphereMesh, "The mesh must be of the QuadMesh or SphereMesh type")
	
	vis.position = Vector2.ZERO
	
	var mesh_size: Vector2
	if mesh is QuadMesh:
		mesh_size = mesh.size
		vis.rect = Rect2(-(mesh_size / 2), mesh_size)
	elif mesh is SphereMesh:
		mesh_size = Vector2(mesh.radius * 2, mesh.height)
		vis.rect = Rect2(-(mesh_size) / 2, mesh_size)
	
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)


func _on_VisibilityNotifier2D_screen_exited():
	pass#material.set_shader_param("active", false)


func _on_VisibilityNotifier2D_screen_entered():
	pass#material.set_shader_param("active", true)
