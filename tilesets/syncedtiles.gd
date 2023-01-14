tool
extends TileMap
export(String,"random","byorder") var intervaltype
export(Array,AudioStream) var audios
export(bool) var synconrun=true
export(bool) var useparticles
export(Array,NodePath) var syncedtiles
export(bool) var update_subtiles setget upd
func _ready():
	$detect.visible=false
	if synconrun:
		upd(0)
func upd(_value):
	var synced=0
	while synced<syncedtiles.size():
		var editing:TileMap=get_node(syncedtiles[synced])
		editing.clear()
		var done=0
		while done<get_used_cells().size():
			var pos=get_used_cells()[done]
			editing.set_cellv(pos,get_cellv(pos))
			editing.update_bitmask_area(pos)
			done+=1
		synced+=1
func getsound(step=0):
	if audios.size()>0:
		var num:int=0
		match intervaltype:
			"random":
				num=round(rand_range(0,audios.size()-1))
			"bystep":
				if audios.size()>step:
					num=step
					step=step+1
				else:
					step=0
		return [audios[num],step]
