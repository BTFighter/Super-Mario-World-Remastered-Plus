class_name SelectableOptionNode
extends OptionNode
@onready var arrow: TextureRect = $MarginContainer/Arrow

@onready var left: TextureRect = $MarginContainer/Container/ValueContainer/Left
@onready var right: TextureRect = $MarginContainer/Container/ValueContainer/Right

@export var node_title := ""
@export_enum("Value", "Index") var option_value_usage := 0
@export var selectable_values := []
@export var value_colours: Array[Color]
@onready var value: Label = $MarginContainer/Container/ValueContainer/Value

var selected_index := 0

var selected_value = null

func update(delta: float) -> void:
	arrow.visible = highlighted
	title.text = "  " + node_title + ":"
	if settings_value == "modified_life_decrement":
		if selectable_values[selected_index] == false:
			value.text = "Original"
		else:
			value.text = "Mario Maker"
	else:
		value.text = str(selectable_values[selected_index])
	left.modulate.a = 1 if highlighted and selected_index > 0 else 0
	if value_colours.is_empty() == false:
		if value_colours[selected_index] != null:
			value.modulate = value_colours[selected_index]
		else:
			value.modulate = Color.WHITE
	right.modulate.a = 1 if highlighted and selected_index < selectable_values.size() - 1 else 0
	if highlighted:
		if Input.is_action_just_pressed("move_right_0"):
			selected_index += 1
			SoundManager.play_ui_sound(SoundManager.select)
		elif Input.is_action_just_pressed("move_left_0"):
			selected_index -= 1
			SoundManager.play_ui_sound(SoundManager.select)
	selected_index = clamp(selected_index,0, selectable_values.size() - 1)
	selected_value = selectable_values[selected_index]
	update_2()

func update_2() -> void:
	pass

func get_chosen_val():
	if option_value_usage == 0:
		return selected_value
	else:
		return selected_index
