extends CharacterBody2D


@export var speed = 100.0


@onready var anim = get_node("AnimationPlayer")
@onready var sprite = get_node("Crab_M1")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = -1


func _physics_process(delta):

	if not is_on_floor():
		velocity.y += gravity * delta
	
	if direction != 0:
		sprite.flip_h = (direction == 1)
		
	velocity.x = direction * speed
	animation_update()
	
	move_and_slide()

func animation_update():
	anim.play("crab_idle")

func _on_area_2d_body_entered(body):
	print(body)
	if body is TileMap:
		direction = direction * -1
	else:
		print("fuck")
	
