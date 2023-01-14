extends KinematicBody2D

signal anim_update

var health = Health.new()

export var move_speed := 50
var move_target:Vector2
export var patrol_route:NodePath


func _ready() -> void:
	health.connect("death", self, "death")
	$Timer.connect("timeout", self, "attack")
	if (patrol_route):
		var patrol_points:Array
		for point in get_node(patrol_route).get_children():
			patrol_points.append(point.global_position)
	
		$BehaviorTree.memory["patrol_route"] = patrol_points


func _physics_process(_delta: float) -> void:
	$BehaviorTree.tick()
	var direction:Vector2
	if (move_target != Vector2.ZERO):
		direction = global_position.direction_to(move_target)
		move_and_slide(direction*move_speed)
		var distance = global_position.distance_to(move_target)
		if distance < 5:
			move_target = Vector2.ZERO
	
	emit_signal("anim_update", direction)


func damage(amount:int):
	health.damage(amount)
	$HitSound.stream.loop = false
	$HitSound.play()
	$StabSound.stream.loop = false
	$StabSound.play()
	if (health.current_health <= 20):
		$visual.bloody = true


func move_to(pos:Vector2):
	move_target = pos


func attack():
	var bodies = $AttackArea.get_overlapping_bodies()
	for body in bodies:
		if (body.has_method("damage") && body != self):
			body.damage(10)


func death():
	print(name + " has died")
	queue_free()
