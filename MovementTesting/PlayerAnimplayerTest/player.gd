extends CharacterBody2D
class_name PlayerAnimPlayer

const BLASTER_POS = 10
const BASE_SPEED = 150
const CRAWL_SPEED = 150
const SLIDE_SPEED = 750
const SLIDE_LENGTH = 0.5

@export var gravity = 500
@export var speed = 150
@export var jump_velocity = 250.0
@export var stomp_velocity = 300.0
@onready var anim = get_node("AnimationPlayer")
@onready var sprite = get_node("Sprite_Blaster")
@onready var blast_con = $BlastContainer 
@onready var slide = $Slide
@onready var coyote_timer = $CoyoteTimer
@onready var wall_sliding_timer = $WallSlidingTimer
@onready var cam = $Camera2D
@onready var sm = $StateMachine

var weapon_list: Array = ["Blaster", "Test"]
var weapon_selected = 0
var blast_scene = preload("res://scenes/blast.tscn")
var cur_action = ""
var cur_weapon = ""
var cur_anim = ""
var is_shoot_active = false
var is_crouched = false
var is_jumping = false
var is_wall_jumping = false
var is_wall_sliding = false
var is_head_bump = false
var direction_hold = 1
var slide_cooldown = true
var wall_slide_cooldown = true

func _ready():
	cur_action = "Idle"
	cur_weapon = "_Blaster"
	
	cur_anim = cur_action + cur_weapon
	
#	sm.add_state("idle")
#	sm.add_state("run")
#	sm.add_state("jump")
#	sm.add_state("crouch")
#	sm.add_state("slide")
#	sm.add_state("wall_slide")
#	call_deferred("set_state", sm.states.idle)
#
#	print(sm.parent)

func _process(delta):
	if cur_weapon == "_Test" && Input.is_action_just_pressed("shoot") && not is_on_floor():
		stomp(stomp_velocity)
	elif Input.is_action_just_pressed("shoot") && not is_crouched:
		shoot()
	elif Input.is_action_just_released("shoot") && not is_crouched:
		shoot()
	if Input.is_action_just_pressed("swap_weapon_left"):
		swap_weapon("left")
	if Input.is_action_just_pressed("swap_weapon_right"):
		swap_weapon("right")
	
		
func _physics_process(delta): 
	var direction = Input.get_axis("left", "right")
	
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y >= 500:
			velocity.y = 500
	else: 
		cam.position_smoothing_enabled = false
		is_jumping = false
		is_wall_sliding = false
		is_wall_jumping = false
		
	if is_on_wall() && !is_on_floor():
		is_wall_sliding = true
		if Input.is_action_pressed("left") || Input.is_action_pressed("right"):
			if wall_slide_cooldown:
				velocity.y = 0
				wall_slide_cooldown = false
			else: gravity = 100
			
		else:
			gravity = 500
	else: 
		is_wall_sliding = false
		wall_slide_cooldown = true
		gravity = 500
	
	
	if Input.is_action_just_pressed("jump") && !is_head_bump:
		if (is_on_floor() || !coyote_timer.is_stopped()):
			is_jumping = true
			jump(jump_velocity)
		elif is_on_wall():
			is_wall_jumping = true
			cam.position_smoothing_enabled = true
			cam.position_smoothing_speed = 20 
			velocity.x = 1000 * (direction_hold * -1)			
			jump(250.00)
		
	if Input.is_action_pressed("crouch") && !is_jumping:
		is_crouched = true
		
		if Input.is_action_just_pressed("shoot") && slide_cooldown:
			slide.start_slide(SLIDE_LENGTH)
			speed = SLIDE_SPEED
			slide_cooldown = false
			
		if slide.is_sliding() && speed > 0:
			if direction == 0:
				direction = direction_hold
			speed -= 25
		else:
			speed = BASE_SPEED
	else:
		if is_head_bump == false:
			is_crouched = false
			slide_cooldown = true
		
	if direction != 0:
		direction_hold = direction
		sprite.flip_h = (direction == -1)
		
	if !is_on_wall():
		is_wall_sliding = false
		is_wall_jumping = false
	
	if !is_jumping && !is_on_floor() && !is_on_wall():
		coyote_timer.start()
#
#	print(velocity.y)
	if !is_wall_jumping:
		velocity.x = direction * speed
	move_and_slide()
	animation_update(direction)
#	print(get_real_velocity())

func animation_update(direction):
	if is_on_floor():
		if direction == 0:
			if is_shoot_active:
				anim.play("Idle_Shoot"  + cur_weapon)
			elif is_crouched:
				anim.play("Idle_Crouch" + cur_weapon)
			else:
				anim.play("Idle" + cur_weapon)
		else:
			if is_shoot_active:
				anim.play("Run_Shoot" + cur_weapon)
			elif is_crouched:
				if slide.is_sliding():
					anim.play("Sliding" + cur_weapon)
				else:
					anim.play("Run_Crouch" + cur_weapon)
			else:
				anim.play("Run" + cur_weapon)
	else:
		if velocity.y:
			if is_wall_sliding: 
				if is_shoot_active:
					anim.play("Wall_Sliding_Shoot"  + cur_weapon)
				else:
					anim.play("Wall_Sliding" + cur_weapon) 
			else:
				if is_shoot_active:
					anim.play("Jump_Shoot"  + cur_weapon)
				else:
					anim.play("Jump" + cur_weapon)
		#else:
			#anim.play("Fall")

func jump(force):
	velocity.y = -force

func swap_weapon(input):
	var hold = weapon_list.size() - 1
	print(weapon_selected)
	
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
	
	if is_wall_sliding:
		if sprite.flip_h:
			blast_inst.spr.flip_h = false
			blast_inst.global_position.x += BLASTER_POS 
			blast_inst.speed = 300
		
		else:
			blast_inst.spr.flip_h = true
			blast_inst.global_position.x += -BLASTER_POS 
			blast_inst.speed = -300
	
	else: 
		if sprite.flip_h:
			blast_inst.spr.flip_h = true
			blast_inst.global_position.x += -BLASTER_POS 
			blast_inst.speed = -300
		
		else:
			blast_inst.spr.flip_h = false
			blast_inst.global_position.x += BLASTER_POS 
			blast_inst.speed = 300
	
	if !is_shoot_active:
		shoot_toggle(direction)

func shoot_toggle(direction):
	is_shoot_active = true
	if direction == 0:
		await get_tree().create_timer(0.5).timeout
		is_shoot_active = false
	else:
		await get_tree().create_timer(1).timeout
		is_shoot_active = false

#func slide(direction_hold, force, speed):
#	print("slide")
#	velocity.x = speed * force
#	print(velocity.x)

func stomp(force):
	velocity.y = force

func _on_head_bump_check_body_entered(body):
	if body is TileMap:
		is_head_bump = true

func _on_head_bump_check_body_exited(body):
	if body is TileMap:
		is_head_bump = false
