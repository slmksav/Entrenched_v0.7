extends Node
var actual:Area2D
var interacterhistory=[]
func enteredselector(who:Area2D):
	actual=who
	interacterhistory.append(who)
func outofselector():
	if interacterhistory.size()>1:
		var last=interacterhistory[interacterhistory.size()-2]
		if last!=null and is_instance_valid(last):
			if last.get_overlapping_bodies().size()<1:
				actual=null
			else:
				actual=last
				last.bodyentered(null)
				interacterhistory.append(last)
	else:
		actual=null
