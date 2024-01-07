extends CharacterBody2D
class_name Player

const BLASTER_POS = 10

var blast_scene = preload("res://scenes/blast.tscn")
var is_shoot_active = false

@export var gravity = 400
@export var speed = 125
@export var jump_velocity = 200.0
@export var stomp_velocity = 300.0
@onready var anim = get_node("AnimatedSprite2D")
@onready var blast_con = $BlastContainer 

var weapon_list: Array = ["Blaster", "Test"]
var weapon_selected = 0

var cur_action = ""
var cur_weapon = ""
var cur_anim = ""
var is_crouched = false

func _ready():
	cur_action = "Idle_New"
	cur_weapon = "_Blaster"
	
	cur_anim = cur_action + cur_weapon
	print(cur_anim)

func _process(delta):
	if cur_weapon == "_Test" && Input.is_action_just_pressed("shoot") && not is_on_floor():
		stomp(stomp_velocity)
	elif Input.is_action_just_pressed("shoot"):
		shoot()
		
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y >= 500:
			velocity.y = 500

	if Input.is_action_just_pressed("jump") && is_on_floor():
		jump(jump_velocity)
		
	if Input.is_action_just_pressed("swap_weapon_left"):
		swap_weapon("left")
	if Input.is_action_just_pressed("swap_weapon_right"):
		swap_weapon("right")

	var direction = Input.get_axis("left", "right")
	if direction != 0:
		anim.flip_h = (direction == -1)
	
	#if Input.is_action_just_pressed("crouch"):
	
	velocity.x = direction * speed
	move_and_slide()
	animation_update(direction)

func animation_update(direction):
	if is_on_floor():
		if direction == 0:
			if is_shoot_active:
				anim.play("Idle_Shoot"  + cur_weapon)
			else:
				anim.play("Idle" + cur_weapon)
		else:
			if is_shoot_active:
				anim.play("Run_Shoot" + cur_weapon)
			else:
				anim.play("Run" + cur_weapon)
	else:
		if velocity.y < 0:
			if is_shoot_active:
				anim.play("Jump_Shoot"  + cur_weapon)
			else:
				anim.play("Jump" + cur_weapon)
		#else:
			#anim.play("Fall")

func jump(force):
	velocity.y = -force

func swap_weapon(input):
	print(weapon_list.size())
	var hold = weapon_list.size() - 1
	
	if input == "right":
		if weapon_selected == hold:
			weapon_selected = 0
		else:
			weapon_selected = weapon_selected + 1
	if input == "left":
		if weapon_selected == 0:
			weapon_selected = hold
		else:
			weapon_selected = weapon_selected - 1
	#weapon_selected 
	cur_weapon = "_" + str(weapon_list[weapon_selected])
	print(cur_weapon)

func shoot():
	var direction = Input.get_axis("left", "right")
	var blast_inst = blast_scene.instantiate()
	blast_con.add_child(blast_inst)
	blast_inst.global_position = global_position
	
	if anim.flip_h:
		blast_inst.global_position.x += -BLASTER_POS 
		blast_inst.speed = -300
		
	else:
		blast_inst.global_position.x += BLASTER_POS 
		blast_inst.speed = 300
	
	if !is_shoot_active:
		print("hit")
		shoot_toggle(direction)

func shoot_toggle(direction):
	is_shoot_active = true
	print(direction)
	if direction == 0:
		await get_tree().create_timer(0.5).timeout
		is_shoot_active = false
	else:
		await get_tree().create_timer(1).timeout
		is_shoot_active = false
	
func stomp(force):
	print("ready for ground pound")
	velocity.y = force
	
