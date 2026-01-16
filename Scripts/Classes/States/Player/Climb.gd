extends PlayerState

var punching := false

var facing_back := false

var action := "Idle"
var direction := "Back"

var turning := false

@onready var punch_shape: CollisionShape2D = $"../../AttackBoxes/FencePunchHitbox/Shape"
@onready var climb_sfx: AudioStreamPlayer2D = $"../../ClimbSFX"


var turn_progress := 0.0

var last_valid_move_vector := Vector2.ZERO

var start_position = Vector2.ZERO
var turn_position = Vector2.ZERO

func enter(_msg := {}) -> void:
	if player.z_index == 0:
		direction = "Back"
	else:
		direction = "Front"
	player.climbing = true
	climb_sfx.play()

func exit() -> void:
	player.climbing = false
	climb_sfx.stop()

func physics_update(delta: float) -> void:
	if turning:
		handle_turning(delta)
	else:
		handle_climbing(delta)
	if direction == "Back":
		player.z_index = 0
	else:
		player.z_index = -3
	punch_shape.set_deferred("disabled", not punching)

func handle_climbing(delta: float) -> void:
	var climb_direction := Vector2.ZERO
	if Input.is_action_pressed(CoopManager.get_player_input_str("move_left", player.player_id)):
		climb_direction.x = -1
	elif Input.is_action_pressed(CoopManager.get_player_input_str("move_right", player.player_id)):
		climb_direction.x = 1
	else:
		climb_direction.x = 0
	if player.climb_x_lock:
		climb_direction.x = 0
	
	if Input.is_action_pressed(CoopManager.get_player_input_str("move_up", player.player_id)):
		climb_direction.y = -1
	elif Input.is_action_pressed(CoopManager.get_player_input_str("move_down", player.player_id)):
		climb_direction.y = 1
	else:
		climb_direction.y = 0
	player.sprite_speed_scale = 1
	if player.is_on_floor() and climb_direction.y == 1:
		state_machine.transition_to("Normal")
		player.crouching = false
		return
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
		state_machine.transition_to("Normal", {"Jump" = true})
		return
	if punching:
		action = "Punch"
	elif climb_direction == Vector2.ZERO:
		climb_sfx.stop()
		action = "Idle"
	else:
		if climb_sfx.is_playing() == false:
			climb_sfx.play()
		action = "Move"
	player.current_animation = "Climb" + action + direction
	
	if player.climb_punch:
		if Input.is_action_just_pressed(CoopManager.get_player_input_str("run", player.player_id)):
			punch()

	if player.hitbox_area.get_overlapping_areas().any(player.is_climbable) == false:
		state_machine.transition_to("Normal")
		return
	if not punching:
		if player.climb_x_lock:
			player.global_position.x = player.climb_x_position
		player.velocity = (climb_direction.normalized() * (player.climb_sprint if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)) else player.climb_speed))
		last_valid_move_vector = player.velocity
	else:
		player.velocity = Vector2.ZERO

	if SettingsManager.settings_file.fast_climb == true:
		player.velocity = (climb_direction.normalized() * (player.fast_climb_sprint if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)) else player.fast_climb_speed))

func handle_turning(delta: float) -> void:
	player.velocity = Vector2.ZERO

func punch() -> void:
	punching = true
	SoundManager.play_sfx(SoundManager.bump, player)
	await get_tree().create_timer(0.1, false).timeout
	punching = false
	if player.flip_panel != null:
		turn()

func animate_turn() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player, "global_position", Vector2(turn_position.x, player.global_position.y), 0.5)
	await get_tree().create_timer(0.25, false).timeout
	if direction == "Back":
		direction = "Front"
	else:
		direction = "Back"

func turn() -> void:
	if state_machine.state != self:
		return
	if player.global_position.x > player.flip_panel.global_position.x:
		player.sprite.scale.x = 1
		if direction == "Back":
			player.current_animation = "ClimbTurn"
		else:
			player.current_animation = "ClimbTurnBack"
	else:
		player.sprite.scale.x = -1
		if direction == "Back":
			player.current_animation = "ClimbTurn"
		else:
			player.current_animation = "ClimbTurnBack"
	SoundManager.play_sfx("res://Assets/Audio/SFX/suit-remove.wav", player)
	turn_progress = 0
	turning = true
	start_position = player.global_position
	turn_position = player.flip_panel.player_marker.global_position
	turn_position = player.flip_panel.to_local(turn_position)
	turn_position.x *= -2
	turn_position = player.to_global(turn_position)
	animate_turn()
	player.flip_panel.animate_turn()
	await get_tree().create_timer(0.5, false).timeout
	turning = false
	
