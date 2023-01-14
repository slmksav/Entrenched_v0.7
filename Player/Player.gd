extends movingentity
class_name Player,"res://Player/classicon.png"

export(float) var hunger = 100
export(float) var hunger_per_min = 2.5
export(bool) var infected = false
export(float, 0, 100) var sick = 0
export(float) var default_sick_cooldown = 1
export(Array, AudioStream) var puke_sounds
export(float) var max_puke_interval = 120
export(float) var min_puke_interval = 30
export(Gradient) var puke_gradient

var starve_cooldown = 5
var setui: bool = true
var is_client: bool = false
var gray_screen_active: bool = false
var torch_stand : Area2D
var sick_cooldown = default_sick_cooldown
var puke_cooldown : float = 0
var recovering = false
var sitting = false

onready var inventory:Control = $UI/center/inventorycontainer/inventory as Control
onready var healthui = $UI/health
onready var hungerBar = $UI/health/hunger
onready var inithit = $HitSound.stream

#onready var screen_effect: ColorRect
onready var screen_anim: AnimationPlayer = $screen_effects_container/screen_animation_player
onready var death_anim: AnimationPlayer = $DeathAnim
export(int) var inputpriority


func _ready() -> void:
	connect("attacked", self, "_on_attacked")
	connect("death", self, "_on_death")
	
	healthui.get_node("lifebar").value = health + 16 # The bar has an extra 16 because of the icon at the front
	$visual.playing = false
	$visual.frame = 0
	
	add_to_group("player")
	
	if not Multiplayer.is_online_mode():
		if globals.player != self:
			globals.set_player(self)
	
	start_hunger()
	$visual/chest.waitforskin()
	
	puke_cooldown = rand_range(min_puke_interval, max_puke_interval)



func _physics_process(delta: float):
	var input_vector=Vector2.ZERO
	if canmove:
		input_vector.x = smartinput.getforce("move_right",inputpriority) - smartinput.getforce("move_left",inputpriority)
		input_vector.y = smartinput.getforce("move_down",inputpriority) - smartinput.getforce("move_up",inputpriority)
		input_vector = input_vector.normalized()
		emit_signal("canmove",input_vector)
		if moveonframe:
			if input_vector != Vector2.ZERO:
				velocity = velocity.move_toward(input_vector * movespeed, ACCELERATION * delta)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			if input_vector != Vector2.ZERO:
				var look: float
				if not $visual.dovertical:
					if input_vector.x > 0:
						look = (3*PI)/2
					elif input_vector.x < 0:
						look = PI/2
					else:
						look = lookingto
				else:
					look = math.getlookatfromvec(input_vector)
				if look != null:
					lookingto = look
		else:
			velocity = Vector2.ZERO
		velocity = move_and_slide(velocity)
		moveonframe = true
	emit_signal("updatesprite",input_vector)
	
	
	
	
	########################################
	"""
	  DON'T TOUCH THIS FUNCTION!   >:u
	
	  I added the sitting part (it really shouldn't mess anything up)
	"""
	aftermove()
	########################################


func setmove() -> Vector2:
	var input_vector: Vector2 = Vector2()
	input_vector.x = smartinput.getforce("move_right",inputpriority) - smartinput.getforce("move_left",inputpriority)
	input_vector.y = smartinput.getforce("move_down",inputpriority) - smartinput.getforce("move_up",inputpriority)
	return input_vector

func aftermove():
	if not Multiplayer.is_online_mode() or (not Multiplayer.is_client() and not is_client): return
	Multiplayer.send_player_state({"P": global_position})

func _process(delta: float):
	starve_cooldown -= delta
	sick_cooldown -= delta
	puke_cooldown -= delta
	# Hunger
	if hunger <= 0 and starve_cooldown <= 0:
		hunger = 0
		starve_cooldown = 5
		damage(1, 0)
	# Sickness
	if infected:
		# Phase 2
		if sick > 50:
			movespeed = defmovespeed/2
		elif sick <= 50:
			movespeed = defmovespeed
		# Phase 3
		if sick == 100 and sick_cooldown < 0:
			sick_cooldown = default_sick_cooldown
			damage(1, 0)
		# Puking
		if sick > 40 and puke_cooldown < 0:
			healthui.get_node("hunger/Tween").stop(hungerBar)
			hunger -= 1
			start_hunger()
			puke_cooldown = rand_range(min_puke_interval, max_puke_interval)
			puke_sounds.shuffle()
			$PukeSound.stream = puke_sounds[0]
			$PukeSound.play()
			if sick >= 85:
				health -= 1
				$PukeParticles.process_material.color = puke_gradient.interpolate((sick-85)/15)
			else:
				$PukeParticles.process_material.color = puke_gradient.interpolate(0)
			$PukeParticles.emitting = true
			globals.camera.shake(0.3, 1.5)
	if recovering and sick_cooldown < 0:
		sick_cooldown = default_sick_cooldown
		sick -= 0.2
	if not recovering and sick_cooldown < 0:
		sick_cooldown = default_sick_cooldown
		sick += 0.2
	# Update the numbers on the UI bars
	hunger = (hungerBar.value) / 100 - 35 # the extra 35 is due to the icon at the front
	healthui.get_node("lifebar/text").text = str(health)
	healthui.get_node("hunger/text").text = str(round(hunger))
	# Sitting
	if Input.is_action_just_pressed("sit"):
		$visual.playanim("sit")
		sitting = true


func set_armor(new_armor:Armor):
	setentityarmor(new_armor)
	$HitSound.stream = new_armor.hit_sound
	if $HitSound.stream != null:
		$HitSound.stream.loop = false


func unset_armor(armor:Armor):
	unsetentityarmor(armor)
	$HitSound.stream=inithit


#called by the entity class after the damage
#has been processed
func customdamage(_amount:int,real:bool):
	if not real:
		$visual.bloody=health<= 20
		$HitSound.play()
		$StabSound.play()
		globals.camera.shake(1, 3)
	healthui.get_node("lifebar").value = health
	healthui.get_node("lifebar").get_node("text").text = str(health)


func sethealth(prev_health,new_health):
	var life_tween: Tween = get_node("health/lifebar/Tween")
	life_tween.interpolate_property(healthui.get_node("lifebar"), "value", prev_health, new_health, 1.2, Tween.TRANS_SINE)
	life_tween.start()
	#healthui.get_node("lifebar").value = health
	healthui.get_node("lifebar").get_node("text").text = str(health)
	if health > math.percent(25, max_health) and gray_screen_active:
		screen_anim.play_backwards("low_health")


func start_hunger():
	var hungerTween: Tween = healthui.get_node("hunger/Tween")
	hungerTween.interpolate_property(hungerBar, "value", (hunger + 35) * 100, (hunger - hunger_per_min + 35) * 100, 60, Tween.TRANS_LINEAR)
	hungerTween.start()


func _on_Tween_tween_completed(object, key):
	start_hunger()


func _on_attacked(dmg: int, by: Node = null):
	screen_anim.play("hit")
	
	if health <= math.percent(25, max_health) and not gray_screen_active:
		screen_anim.play("low_health")
	elif health > math.percent(25, max_health) and gray_screen_active:
		screen_anim.play_backwards("low_health")


func _on_death(by: Node = null, cause: String = ""):
	globals.logger("player has died - cause: " + cause)
	$visual/shadow.visible = false
	canmove = false
	death_anim.play("death")
	yield(death_anim, "animation_finished")
	dead_particles()
	$visual.visible = false
	globals.logger("spawning in 5 seconds")
	yield(get_tree().create_timer(5), "timeout")
	if not is_client: globals.camera.set_process(false)
	queue_free()
	globals.world.spawn_player(Vector2.ZERO, name)


func dead_particles():
	get_node("DeadParticles").start()






