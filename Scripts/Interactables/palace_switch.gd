extends StaticBody2D

@export_enum("Yellow", "Green", "Blue", "Pink") var switch_colour := 0

@export var message: Texture2D = null

@onready var sprite: Sprite2D = $Sprite

var can_activate := true

signal pressed
signal all_switches_pressed

func _ready() -> void:
	sprite.frame += switch_colour




func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if area.get_parent().velocity.y > 0:
			activate_switch()

func activate_switch() -> void:
	if can_activate == false:
		return
	sprite.frame += 4
	pressed.emit()
	SoundManager.play_sfx(SoundManager.switch_activate, self)
	SoundManager.play_sfx(SoundManager.bullet, self)
	GameManager.show_message(message, 0)
	MusicPlayer.play_course_clear_fanfare()
	GameManager.colours_enabled[switch_colour] = true
	if GameManager.colours_enabled.any(func(val): return val == false) == false:
		all_switches_pressed.emit()
	await GameManager.message_closed
	MusicPlayer.stop_level_music()
	TransitionManager.transition_to_map(GameManager.current_map_path, GameManager.current_level, true)
