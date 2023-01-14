extends Node
export(String,"roundup","rounddown","disabled") var alignment
export(PoolStringArray) var exeptions
func doalign():
	if alignment=="disabled" or get_parent().headreference==null:return
	for element in get_parent().get_children():
		if not (exeptions as Array).has(element.name):
			var anim=get_parent().headreference.get_node_or_null(get_parent().animation)
			if anim!=null:
				var reference=anim.get_node_or_null(element.name)
				if reference!=null:
					var texture:Texture
					if element is Sprite:
						texture=element.texture
					if element is AnimatedSprite:
						if element.frames!=null:
							texture=element.frames.get_frame(element.animation,0)
					if texture!= null:
						var reftexture:Texture
						if reference is Sprite:
							reftexture=reference.texture
						if reference is AnimatedSprite:
							reftexture=reference.frames.get_frame(get_parent().animation,0)
						if not ((texture.get_height()%2==0)==(reftexture.get_height()%2==0)):
							if alignment=="rounddown":
								element.offset.y=0.5
							else:
								element.offset.y=-0.5
						else:
							element.offset.y=0
