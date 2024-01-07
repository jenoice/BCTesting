extends Area2D

@export var speed = 300
@onready var visiable_notifier = $VisibleOnScreenNotifier2D
@onready var spr = $Bullet_Sprite

func _ready():
	
	visiable_notifier.connect("screen_exited", _on_screen_exited)

func _physics_process(delta):
	global_position.x += speed*delta
	
func _on_screen_exited():
	queue_free()
	
func _on_area_entered(area):
	queue_free()
	area.die()

func flip_sprite(dir):
	pass
