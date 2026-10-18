extends Control

var active := false
var current_player_id := 0
@onready var label: Label = $Label

signal finished
signal closed

var assigned_joypads = []

var primary_actions = [preload("res://Resources/Inputs/dive.tres"), preload("res://Resources/Inputs/jump.tres"), preload("res://Resources/Inputs/move_down_stick.tres"), preload("res://Resources/Inputs/move_left_stick.tres"), preload("res://Resources/Inputs/move_right_stick.tres"), preload("res://Resources/Inputs/move_up_stick.tres"), preload("res://Resources/Inputs/run.tres"), preload("res://Resources/Inputs/spin_jump.tres")]
var primary_strings = ["dive", "jump", "move_down", "move_left", "move_right", "move_up", "run", "spin_jump"]

var secondary_actions = [preload("res://Resources/Inputs/move_down_pad.tres"), preload("res://Resources/Inputs/move_left_pad.tres"), preload("res://Resources/Inputs/move_right_pad.tres"), preload("res://Resources/Inputs/move_up_pad.tres"), preload("res://Resources/Inputs/run_2.tres"), preload("res://Resources/Inputs/spin_jump_2.tres")]
var secondary_strings = ["move_down", "move_left", "move_right", "move_up", "run", "spin_jump"]

func _ready() -> void:
	hide()

func _process(delta: float) -> void:
	label.modulate = CoopManager.player_colours[current_player_id]
	label.text = "P" + str(current_player_id + 1) + "\n Press Any Button..." + "\n Press ESC to Cancel.."
	if active:
		if Input.is_action_just_pressed("ui_back"):
			cancel_assignment()

func open() -> void:
	InputMap.load_from_project_settings()
	assigned_joypads = []
	show()
	current_player_id = 0
	remove_inputs()
	await get_tree().create_timer(0.1).timeout
	active = true

func remove_inputs() -> void:
	for p in 4:
		for i in primary_strings:
			for a in InputMap.action_get_events(CoopManager.get_player_input_str(i, p)):
				if a is InputEventKey == false:
					InputMap.action_erase_event(CoopManager.get_player_input_str(i, p), a)
		for i in secondary_strings:
			for a in InputMap.action_get_events(CoopManager.get_player_input_str(i, p)):
				if a is InputEventKey == false:
					InputMap.action_erase_event(CoopManager.get_player_input_str(i, p), a)

func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_released():
		return
	if Input.is_action_just_pressed("ui_cancel"):
		cancel_assignment()
		return
	if event is InputEventKey and current_player_id == 0:
		proceed()
	elif event is InputEventJoypadButton:
		if assigned_joypads.has(event.device):
			return
		assign_input_to_device(event.device)
		proceed()

func assign_input_to_device(device_id := 0) -> void:
	var action_index := 0
	assigned_joypads.append(device_id)
	CoopManager.player_device_ids[current_player_id] = device_id
	for i: InputEvent in primary_actions:
		var event = i.duplicate(true)
		event.device = device_id
		InputMap.action_add_event(CoopManager.get_player_input_str(primary_strings[action_index], current_player_id), event)
		action_index += 1
	action_index = 0
	for i: InputEvent in secondary_actions:
		var event = i.duplicate(true)
		event.device = device_id
		InputMap.action_add_event(CoopManager.get_player_input_str(secondary_strings[action_index], current_player_id), event)
		action_index += 1

func cancel_assignment() -> void:
	close()
	SoundManager.play_ui_sound(SoundManager.fireball)
	InputMap.load_from_project_settings()

func close() -> void:
	hide()
	active = false
	closed.emit()

func finish() -> void:
	hide()
	for p in 4:
		for a in primary_strings:
			print([CoopManager.get_player_input_str(a, p), InputMap.action_get_events(CoopManager.get_player_input_str(a, p))])
	finished.emit()
	active = false

func proceed() -> void:
	SoundManager.play_ui_sound(SoundManager.coin)
	current_player_id += 1
	active = false
	if current_player_id + 1 > CoopManager.players_connected:
		finish()
		return
	await get_tree().create_timer(0.5).timeout
	active = true
