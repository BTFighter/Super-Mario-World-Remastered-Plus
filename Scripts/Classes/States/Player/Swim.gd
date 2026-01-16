extends PlayerState

var current_speed := 0

const swim_speed := 60
const fast_swim_speed := 100
const hold_swim_speed := 120
const swim_force := -120
const swim_gravity := 1.875
const swim_accel := 5.625
const fast_swim_accel := 7.625
const decel := 3.75
const up_y_max := -180
const neut_y_max := -90
const down_y_max := -30

const walk_speed := 30
const walk_accel := 5.625
const walk_decel = 3.75

var turning := false
var can_turn := false

var swim_meter := 0.0


func enter(_msg := {}) -> void:
	player.velocity.y /= 2
	player.crouching = false
	player.spinning = false
	player.spin_jumping = false
	swim_meter = 0

func physics_update(delta: float) -> void:
	if player.holding:
		handle_hold_swim()
	else:
		if player.is_on_floor():
			handle_ground_movement()
		else:
			handle_swim()
	player.force_crouch_check()
	player.crush_check()
	player.direction = player.facing_direction
	if player.riding_yoshi:
		handle_yoshi()
	if player.velocity.y > 0:
		player.can_bump = true
		
	if SettingsManager.settings_file.fast_swim_accel == true: if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		player.velocity.x = move_toward(player.velocity.x, (fast_swim_speed * player.input_direction) + player.water_current_speed.x, fast_swim_accel)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0 + player.water_current_speed.x, decel)

func handle_swim() -> void:
	can_turn = player.riding_yoshi
	player.handle_turn_stuff()
	swim_meter -= 1
	player.sprite_speed_scale = 1
	handle_swim_animation()
	player.velocity.y += swim_gravity
	player.velocity.y = clamp(player.velocity.y, -9999, 120)
	if player.input_direction != 0:
		player.velocity.x = move_toward(player.velocity.x, (swim_speed * player.input_direction) + player.water_current_speed.x, swim_accel)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0 + player.water_current_speed.x, decel)
	
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
		swim_up()


func swim_up() -> void:
	SoundManager.play_sfx(SoundManager.swim, player)
	player.velocity.y -= 120
	swim_meter = 15
	if Input.is_action_pressed(CoopManager.get_player_input_str("move_down", player.player_id)):
		player.velocity.y = clamp(player.velocity.y, down_y_max, 500)
	elif Input.is_action_pressed(CoopManager.get_player_input_str("move_up", player.player_id)):
		player.velocity.y = clamp(player.velocity.y, up_y_max, 500)
	else:
		player.velocity.y = clamp(player.velocity.y, neut_y_max, 240)

func handle_ground_movement() -> void:
	player.crouching = (Input.is_action_pressed(CoopManager.get_player_input_str("move_down", player.player_id)) and not player.carrying) or player.force_crouch
	if player.input_direction != 0 and not player.crouching:
		player.velocity.x = move_toward(player.velocity.x, walk_speed * player.input_direction, walk_accel)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, walk_decel)
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
		swim_up()
	handle_swim_animation()
	player.handle_turn_stuff()


func hold_swim_up() -> void:
	SoundManager.play_sfx(SoundManager.swim, player)
	player.velocity.y += 120
	swim_meter = 20

func handle_yoshi() -> void:
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)):
		player.yoshi_dismount(false)
		if player.is_on_floor():
			player.velocity.x = -60 * player.direction
			player.velocity.y = -150
		else:
			player.velocity.y = -150
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		player.yoshi_use_tongue()
	if not turning:
		player.yoshi.scale.x = player.sprite.scale.x

func handle_swim_animation() -> void:
	player.sprite_speed_scale = 1
	player.yoshi_animations.speed_scale = 1
	if not player.riding_yoshi:
		if player.spinning:
			player.current_animation = "Spin"
			return
		if player.is_on_floor():
			if player.crouching:
				player.current_animation = "Crouch"
			elif player.input_direction != 0:
				player.current_animation = "Walk"
			else:
				player.current_animation = "Idle"
				if Input.is_action_pressed(CoopManager.get_player_input_str("move_up", player.player_id)):
					player.current_animation = "LookUp"
		elif swim_meter > 0:
			if player.carrying:
				player.current_animation = "CarrySwimUp"
			else:
				player.current_animation = "SwimUp"
		else:
			if player.carrying:
				player.current_animation = "CarrySwimIdle"
			else:
				player.current_animation = "SwimIdle"
	else:
		player.sprite_speed_scale = 1
		if not player.turning:
			player.current_animation = "YoshiIdle"
		else:
			player.current_animation = "YoshiTurn"
			return
		if not player.turning:
			if player.yoshi_animation_override == "":
				if player.is_on_floor():
					if player.input_direction != 0:
						player.yoshi_animations.play("Move")
					else:
						if player.crouching:
							player.yoshi_animations.play("Crouch")
							player.current_animation = "YoshiCrouch"
						else:
							player.yoshi_animations.play("Idle")
				elif swim_meter > 0:
					if SettingsManager.sprite_settings.yoshiswim:
						player.yoshi_animations.play("SwimUp")
					else:
						player.yoshi_animations.play("SwimUpClassic")
				else:
					if SettingsManager.sprite_settings.yoshiswim:
						player.yoshi_animations.play("SwimIdle")
					else:
						player.yoshi_animations.play("Fall")
			else:
				player.yoshi_animations.play(player.yoshi_animation_override)
	if player.animation_override != "":
		player.current_animation = player.animation_override
		
func handle_hold_swim() -> void:
	swim_meter -= 1
	handle_hold_animations()
	player.velocity.x = clamp(player.velocity.x, -hold_swim_speed, hold_swim_speed)
	player.velocity.y -= swim_gravity
	player.velocity.y = clamp(player.velocity.y, -60, 60)
	player.sprite.scale.x = player.facing_direction
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("move_down", player.player_id)):
		hold_swim_up()
	if player.input_direction != 0:
		player.direction = player.input_direction
		player.facing_direction = player.direction
		player.velocity.x = move_toward(player.velocity.x, (hold_swim_speed * player.direction) + + player.water_current_speed.x, swim_accel)
	else:
		player.velocity.x = move_toward(player.velocity.x, (hold_swim_speed * player.direction * 0.5) + + player.water_current_speed.x, swim_accel)

func handle_hold_animations() -> void:
	player.sprite_speed_scale = 1
	player.yoshi_animations.speed_scale = 1
	if swim_meter > 0:
		player.current_animation = "HoldSwimUp"
	else:
		player.current_animation = "HoldSwimIdle"
