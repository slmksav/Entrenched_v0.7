extends Node2D

export(float, 0, 1000, 0.1) var blood_life_time: float = 10
export(Array, StreamTexture) var pool_blood_spr: Array

onready var blood_pool: Sprite = $spr_blood_pool
onready var blood_particle: CPUParticles2D = $BloodParticle
onready var detect_blood: Area2D = $detect_blood
onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	assert(pool_blood_spr.size() > 0)
	
	blood_particle.emitting = true
	
	if pool_blood_spr.size() == 1: blood_pool = pool_blood_spr[0]
	else:
		randomize()
		blood_pool.texture = pool_blood_spr[randi() % pool_blood_spr.size()]
	
	yield(get_tree().create_timer(blood_life_time), "timeout")
	
	anim.play("visible_blood")
func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "visible_blood":
		queue_free()
