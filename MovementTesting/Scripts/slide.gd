extends Node2D

@onready var slide_timer = $Timer

func start_slide(duration):
	print("hit on start")
	slide_timer.wait_time = duration
	slide_timer.start()
	
func is_sliding():
	return !slide_timer.is_stopped()
