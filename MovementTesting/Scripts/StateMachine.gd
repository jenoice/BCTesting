extends Node
class_name StateMachine

var cur_state = null :
	set(value): set_state(value)
var pre_state = null
var states = {}

@onready var parent = get_parent()

func _physics_process(delta):
	if cur_state != null:
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition != null:
			set_state(transition)

func _state_logic(delta):
	pass

func _get_transition(delta):
	return null

func _enter_state(new_state, old_state):
	pass

func _exit_state(old_state, new_state):
	pass

func set_state(new_state):
	pre_state = cur_state
	cur_state = new_state
	
	if pre_state != null:
		_exit_state(pre_state, new_state)
	if new_state != null:
		_enter_state(new_state, pre_state)

func add_state(state_name):
	states[state_name] = states.size()
