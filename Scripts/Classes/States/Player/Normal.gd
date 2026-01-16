extends PlayerState

var can_flutter := true

var min_slope_angle := deg_to_rad(10)
var flutter_meter := 1.0
var flutter_rate := 1
var flutter_boost := 20.0

var jump_queued := false

var can_walljump := true

var skidding := false

var can_turn := false

var air_twirl_meter := 1.0
var air_twirling := false

var yoshi_fly := false

var can_sprint := false

var coyote_frames := 0
var can_coyote := false

var can_move := true

var can_yoshi_stomp := false

const walk_speed := 75.0
const move_speed_modifiers := {"Mario": 1, "Luigi": 0.95, "Toad": 1.25, "Toadette": 1.25}

# When doing slope data structures: first index is ALWAYS moving down the slope. Second index is moving up slope.
const walk_slope_speeds := {Player.Slopes.GRADUAL: [75, 75],
							 Player.Slopes.NORMAL: [90, 63.75],
							 Player.Slopes.STEEP: [135, 56.25],
							Player.Slopes.VERY_STEEP: [135, 0]}

const run_speed := 135.0
const run_slope_speeds := {Player.Slopes.GRADUAL: [135, 135],
							Player.Slopes.NORMAL: [135, 116.75],
							Player.Slopes.STEEP: [135, 61],
							Player.Slopes.VERY_STEEP: [135, 0]}

const sprint_speed := 180.0
const sprint_slope_speeds := {Player.Slopes.GRADUAL: [180, 180],
								Player.Slopes.NORMAL: [180, 180],
								Player.Slopes.STEEP: [180, 180],
								Player.Slopes.VERY_STEEP: [180, 180]}

var current_slope_height := 0.0

const stand_slope_slide := {Player.Slopes.GRADUAL: 0,
							Player.Slopes.NORMAL: 0,
							Player.Slopes.STEEP: 60,
							Player.Slopes.VERY_STEEP: 120}

const sliding_accels := {0: 0,
						Player.Slopes.GRADUAL: 1.875,
						Player.Slopes.NORMAL: 3.75,
						Player.Slopes.STEEP: 5.625,
						Player.Slopes.VERY_STEEP: 9.375}

const sliding_speeds := {Player.Slopes.GRADUAL: 240,
						Player.Slopes.NORMAL: 240,
						Player.Slopes.STEEP: 240,
						Player.Slopes.VERY_STEEP: 240}

const jump_incr := 6.96
const spin_jump_incr := 7.5

const jump_height := 300.0
const spin_jump_height := 266.25

const gravity_modifiers := {"Mario": 1, "Luigi": 0.8, "Toad": 1.1, "Toadette": 1.1}

const accel := 5.265
const accel_modifiers := {"Mario": 1, "Luigi": 0.7, "Toad": 1, "Toadette": 1}
const decel := 3.0

const walk_skid := 9.375
const run_skid := 18.75

const skid_modifiers := {"Mario": 1, "Luigi": 0.5, "Toad": 1, "Toadette": 1}

const DASH_START = preload("res://Instances/Particles/Player/dash_start.tscn")

const ice_mod := 3.0

const air_accel := 5.265
const air_back_accel := 9.375
const air_run_back_accel := 18.75

const max_fall_speed := 240.0
const max_fall_speed_modifiers := {"Mario": 1, "Luigi": 0.9, "Toad": 1.1, "Toadette": 1.1}

const min_slope_angle_slip := 45.0

var steep_sliding := false

var air_lock := false

var physics_style := ""

var jumped := false

var p_balloon_carry := false

var can_extra_move := false # Var used to dictate whether the player can do an extra move (Walljump, Groundpound and stuff)

var can_air_twirl := true

var animation_override := ""

func enter(msg := {}) -> void:
	air_lock = msg.has("WallKick")
	if msg.has("Jump"):
		jump()
	air_twirling = false
	player.crouching = false
	player.current_animation = "Idle"
	player.sprite.show()
	player.skid_sfx.play()
	player.skid_sfx.stream_paused = true


func physics_update(delta: float) -> void:
	player.spinning = player.spin_jumping or player.spin_attacking or air_twirling
	if player.character.custom_properties.has("PhysicsStyle") and SettingsManager.settings_file.character_specific_physics:
		physics_style = player.character.custom_properties.get("PhysicsStyle")
	else:
		physics_style = "Mario"
	player.direction = player.facing_direction
	player.crush_check()
	can_walljump = not player.no_wall_jump
	player.air_twirl_particles.emitting = air_twirling
	player.skid_particles.emitting = (skidding or player.sliding or (player.crouching and abs(player.velocity.x) > 10)) and player.is_on_floor() and not player.on_ice
	if player.carry_target is Player:
		if player.carry_target.state_machine.state.name == "PBalloon":
			p_balloon_carry = true
		else:
			p_balloon_carry = false
	else:
		p_balloon_carry = false
	can_turn = player.holding or (player.riding_yoshi and not player.yoshi_tongue)
	handle_movement(delta)
	if player.holding or player.riding_yoshi:
		player.handle_turn_stuff()
	elif player.input_direction != 0:
		player.facing_direction = player.input_direction
	if player.riding_yoshi:
		handle_yoshi()
	player.current_animation = handle_animation()
	if not player.turning:
		player.yoshi_animations.play(handle_yoshi_animation())

func handle_movement(delta: float) -> void:
	can_extra_move = not player.holding and not player.carrying and not player.riding_yoshi and not player.spin_jumping

	
	if player.hitbox_area.get_overlapping_areas().any(func(area: Area2D): return area.get_parent() is WaterArea):
		state_machine.transition_to("Swim")
		
	if not player.force_crouch or (player.power_state.hitbox_size != "Regular" and not player.riding_yoshi):
		if player.is_on_floor():
			player.crouching = Input.is_action_pressed(CoopManager.get_player_input_str("move_down", player.player_id)) and not player.carrying
	elif player.power_state.hitbox_size == "Regular" or player.riding_yoshi:
		player.crouching = true
	
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("dive", player.player_id)) and SettingsManager.settings_file.dive and can_extra_move and player.input_direction == player.velocity_direction:
		state_machine.transition_to("Dive")
		return
	
	if player.is_on_floor() == false:
		if p_balloon_carry:
			if Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
				player.velocity.y -= 30
			player.velocity.y = clamp(player.velocity.y, -100, 120)
	
	player.gravity = get_gravity()
	player.velocity.y += player.gravity
	player.velocity.y = clamp(player.velocity.y, -999999, max_fall_speed)
	
	if player.is_on_floor():
		handle_ground_movement(delta)
	else:
		handle_air_movement(delta)

func handle_ground_movement(delta: float) -> void:
	
	handle_p_meter()
	handle_slopes()
	
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)) and Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)) and not player.carrying:
		if player.hitbox_area.get_overlapping_areas().any(player.is_carriable):
			player.carry_grab(player.carry_target)
			return
	
	air_twirling = false
	player.fluttering = false
	flutter_meter = 1
	can_flutter = true
	can_coyote = true
	jumped = false
	air_lock = false
	
	if can_yoshi_stomp and player.yoshi_stomp:
		yoshi_earthquake()

	if can_sprint and player.input_direction == player.velocity_direction:
		if player.sprinting == false:
			summon_dash_particle()
		player.sprinting = true
	else:
		player.sprinting = false
	
	skidding = player.input_direction != 0 and player.input_direction != player.velocity_direction and not steep_sliding
	if player.sliding or steep_sliding:
		handle_sliding()
	elif skidding and not player.crouching:
		handle_skidding()
	elif player.input_direction != 0 and not player.crouching and can_move:
		handle_ground_acceleration()
	elif player.input_direction == 0 or player.crouching:
		handle_deceleration(delta)
	
	player.spin_jumping = false
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)) and not player.force_crouch:
		if player.holding and player.can_jump:
			if SettingsManager.settings_file.holding_spin_jump:
				spin_jump()
			else:
				jump()
		elif player.can_jump:
			spin_jump()
	
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
		queue_jump()
	if jump_queued and player.can_jump:
		jump()
	
	if player.on_triangle_block and abs(player.velocity.x) >= ((run_speed * move_speed_modifiers[physics_style]) - 50) and can_extra_move and Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		if player.moving_up_slope:
			state_machine.transition_to("WallRun")

func handle_sliding() -> void:
	var target_accel := sliding_accels[0]
	if is_on_slope():
		var target_speed = sliding_speeds[int(current_slope_height)]
		target_accel = sliding_accels[int(current_slope_height)]
		player.velocity.x = move_toward(player.velocity.x, target_speed * player.slope_direction, target_accel)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, decel)

func handle_slopes() -> void:
	if player.is_on_floor():
		current_slope_height = get_slope_height(player.get_floor_normal())
	else:
		current_slope_height = 0
	
	steep_sliding = current_slope_height == Player.Slopes.VERY_STEEP and not player.sliding
	
	if is_on_slope():
		player.floor_snap_length = 16
	else:
		player.floor_snap_length = 8
	
	if current_slope_height == Player.Slopes.VERY_STEEP:
		handle_sliding()
	
	if is_on_slope() and not player.sliding and player.get_slope_height(player.get_floor_normal()) >= Player.Slopes.STEEP:
		player.sliding = Input.is_action_pressed(CoopManager.get_player_input_str("move_down", player.player_id)) and not player.holding and not player.carrying
	elif abs(player.velocity.x) < 10 and player.sliding:
		player.sliding = false

func get_slope_height(normal := Vector2.UP) -> int:
	var slope_arr := [0, Player.Slopes.GRADUAL, Player.Slopes.NORMAL, Player.Slopes.STEEP, Player.Slopes.VERY_STEEP]
	
	var diff_arr := []
	for i in slope_arr:
		var current_slope_angle = abs(rad_to_deg(normal.angle() + deg_to_rad(90)))
		var diff = abs(current_slope_angle - i)
		diff_arr.append(diff)
	return slope_arr[diff_arr.find(diff_arr.min())]

func is_on_slope() -> bool:
	return current_slope_height != 0

func get_slope_speed(struct := {}) -> float:
	var slope_height := int(current_slope_height)
	if player.moving_up_slope:
		return struct[slope_height][1]
	else:
		return struct[slope_height][0]

func handle_yoshi_flutter_jump(delta: float) -> void:
	player.velocity.y = clamp(player.velocity.y, -75, 150)
	player.velocity.x = clamp(player.velocity.x, -100, 100)
	can_flutter = false
	flutter_meter -= 1 * delta
	player.velocity.y -= flutter_boost / 1.2
	if flutter_meter <= 0:
		player.fluttering = false
	if Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)) == false:
		player.fluttering = false

func handle_air_movement(delta: float) -> void:
	
	handle_p_meter()
	
	if player.velocity.y > 0:
		jumped = false
	
	var air_skid = (player.input_direction != 0 and player.input_direction != player.velocity_direction and not air_lock)
	if air_skid:
		handle_air_skidding()
	elif player.input_direction != 0 and can_move:
		handle_air_acceleration()
	
	if player.fluttering:
		handle_yoshi_flutter_jump(delta)
	
	if Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)) and player.velocity.y > 100 and SettingsManager.settings_file.air_flutter and can_flutter and player.riding_yoshi and not player.fluttering and not player.yoshi_flying:
		player.fluttering = true
	
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)) and SettingsManager.settings_file.air_twirl and player.velocity.y > 0 and not air_twirling and not player.riding_yoshi and can_air_twirl and not player.spin_jumping:
		air_twirl()
	
	can_yoshi_stomp = true
	
	if air_twirling:
		handle_air_twirls(delta)
	
	if can_coyote:
		coyote_frames = 6
		can_coyote = false
	coyote_frames = clamp(coyote_frames - 1, 0, 60)
	if jump_queued and coyote_frames > 0 and SettingsManager.settings_file.coyote_time:
		jump()
	
	if player.yoshi_flying:
		if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
			yoshi_fly = true
			$"../../YoshiFlySFX".play()
			player.yoshi.wings.play("Fly")
			if player.power_state.state_name != "Cape":
				await get_tree().create_timer(0.5, false).timeout
				stop_yoshi_fly()
		if Input.is_action_just_released(CoopManager.get_player_input_str("jump", player.player_id)):
			stop_yoshi_fly()
		if yoshi_fly:
			player.velocity.y = -125
	
	if player.is_on_wall() and SettingsManager.settings_file.wall_jump and player.input_direction != 0 and player.velocity.y > 0 and can_walljump and can_extra_move:
		state_machine.transition_to("WallSlide")
	
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("move_down", player.player_id)) and SettingsManager.settings_file.ground_pound and can_extra_move:
		state_machine.transition_to("GroundPound")
	
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)) and SettingsManager.settings_file.jump_buffer:
		queue_jump()

func handle_ground_acceleration() -> void:
	var target_speed := walk_speed
	if is_on_slope():
		target_speed = get_slope_speed(walk_slope_speeds)
	if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		target_speed = run_speed
		if is_on_slope():
			target_speed = get_slope_speed(run_slope_speeds)
		if can_sprint:
			target_speed = sprint_speed
			if is_on_slope():
				target_speed = get_slope_speed(sprint_slope_speeds)
	var target_accel = accel * accel_modifiers[physics_style]
	if player.on_ice:
		target_accel /= ice_mod
	player.velocity.x = move_toward(player.velocity.x, (target_speed * move_speed_modifiers[physics_style]) * player.input_direction, target_accel)

func handle_skidding() -> void:
	var target_skid := walk_skid
	if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		target_skid = run_skid
	if player.on_ice:
		target_skid /= ice_mod * 1.25
	player.velocity.x = move_toward(player.velocity.x, 1 * player.input_direction, target_skid * skid_modifiers[physics_style])

func handle_air_acceleration() -> void:
	var target_speed := walk_speed
	if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		target_speed = run_speed
		if can_sprint:
			target_speed = sprint_speed
	player.velocity.x = move_toward(player.velocity.x, (target_speed * move_speed_modifiers[physics_style]) * player.input_direction, air_accel * accel_modifiers[physics_style])

func handle_air_skidding() -> void:
	var target_skid := air_back_accel
	if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		target_skid = air_run_back_accel
	player.velocity.x = move_toward(player.velocity.x, 1 * player.input_direction, target_skid * skid_modifiers[physics_style])

func handle_yoshi() -> void:
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)):
		player.yoshi_dismount(false)
		if player.is_on_floor():
			spin_jump()
			player.velocity.x = -60 * player.direction
			player.velocity.y = -240
		else:
			player.velocity.y = -360
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		player.yoshi_use_tongue()

func handle_p_meter() -> void:
	if abs(player.velocity.x) >= (run_speed) and Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)) and player.is_on_floor():
		player.p_meter += 2
	else:
		if not player.is_on_floor():
			if not player.sprinting:
				player.p_meter -= 1
		else:
			player.p_meter -= 1
	player.p_meter = clamp(player.p_meter, 0, player.p_max)
	can_sprint = player.p_meter >= player.p_max

func handle_deceleration(delta: float) -> void:
	var stop_speed := 0
	if is_on_slope():
		stop_speed = stand_slope_slide[int(current_slope_height)]
	var target_decel = decel
	if player.on_ice:
		target_decel /= ice_mod
		stop_speed *= ice_mod * 2
	player.velocity.x = move_toward(player.velocity.x, stop_speed * player.slope_direction, target_decel)

func queue_jump() -> void:
	jump_queued = true
	player.jump_buffer.start()
	await player.jump_buffer.timeout
	jump_queued = false

func jump() -> void:
	player.sliding = false
	player.spin_jumping = false
	jump_queued = false
	coyote_frames = 0
	can_coyote = false
	if player.can_jump:
		player.velocity.y = calculate_jump_height()
		player.play_sfx("big_jump")
	jumped = true

func spin_jump() -> void:
	player.sliding = false
	player.spin_jumping = true
	player.crouching = false
	player.velocity.y = calculate_jump_height()
	player.play_sfx("spin")

func get_gravity() -> float:
	if Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)) or Input.is_action_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)):
		return player.jump_gravity * gravity_modifiers[physics_style]
	else:
		return player.fall_gravity * gravity_modifiers[physics_style]

func handle_air_twirls(delta: float) -> void:
	air_twirl_meter -= 1 * delta
	player.velocity.y = clamp(player.velocity.y, -INF, 40)
	if air_twirl_meter <= 0:
		air_twirling = false

func air_twirl() -> void:
	air_twirling = true
	can_air_twirl = false
	air_twirl_meter = 0.2
	player.play_sfx("air_twirl")
	await get_tree().create_timer(0.5, false).timeout
	can_air_twirl = true

func calculate_jump_height() -> float: # Thanks wye love you xxx
	var base_speed := jump_height
	var base_incr := jump_incr
	if player.spin_jumping:
		base_speed = spin_jump_height
		base_incr = spin_jump_incr
	return -(base_speed + base_incr * int(abs(player.velocity.x) / 30))
	
func handle_animation(): ## UGHHHHHHHHHHHHHHHHHHHHHHH
	player.sprite.scale.x = player.facing_direction
	if not player.turning and not player.spin_jumping or player.spin_attacking:
		player.sprite_speed_scale = abs(player.velocity.x) / 40
		if player.moving_up_slope and player.get_floor_angle() >= player.Slopes.STEEP:
			player.sprite_speed_scale *= 2
		if player.on_ice:
			player.sprite_speed_scale *= 2
	else:
		player.sprite_speed_scale = 1
	if player.animation_override != "":
		player.sprite_speed_scale = 1
		return player.animation_override
	if player.riding_yoshi:
		if player.turning:
			return "YoshiTurn"
		elif player.crouching or player.sliding:
			return "YoshiCrouch"
		else:
			return "YoshiIdle"
	if player.turning:
		if player.holding:
			return "FaceForward"
	if player.sliding and not steep_sliding:
		return "Slide"
	if air_twirling:
		player.sprite_speed_scale = 1
		if player.carrying:
			return "CarrySpin"
		else:
			return "AirTwirl"
	if player.spin_jumping or player.spin_attacking:
		player.sprite_speed_scale = 1
		if player.carrying:
			return "CarrySpin"
		return "Spin"
		
	if player.crouching:
		if player.holding:
			return "HoldCrouch"
		return "Crouch"
	elif player.is_on_floor():
		if skidding and not player.holding and not player.carrying and not player.on_ice:
			return "Skid"
		elif abs(player.velocity.x) < 10:
			if player.holding:
				if Input.is_action_pressed(CoopManager.get_player_input_str("move_up", player.player_id)):
					return "HoldLookUp"
				return "HoldIdle"
			elif player.carrying:
				return "CarryIdle"
			elif Input.is_action_pressed(CoopManager.get_player_input_str("move_up", player.player_id)):
				return "LookUp"
			else:
				return "Idle"
		elif not player.sprinting:
			if player.holding:
				return "HoldMove"
			elif player.carrying:
				return "CarryWalk"
			return "Walk"
		else:
			if player.holding:
				return "HoldMove"
			elif player.carrying:
				return "CarryWalk"
			if physics_style == "Toad":
				return "FastRun"
			return "Run"
	elif not player.carried:
		if physics_style == "Luigi":
			player.sprite_speed_scale = 5
			if player.holding:
				return "HoldMove"
			elif player.carrying:
				return "CarryWalk"
			elif player.sprinting:
				return "RunJump"
			elif player.velocity.y < 0:
				return "LFlutterJump"
			else:
				return "LFlutterFall"
		elif player.velocity.y < 0 and jumped:
			if player.holding:
				return "HoldJump"
			elif player.carrying:
				return "CarryJump"
			elif player.sprinting:
				return "RunJump"
			return "Jump"
		else:
			if player.holding:
				return "HoldFall"
			elif player.carrying:
				return "CarryFall"
			elif player.sprinting:
				return "RunJump"
			return "Fall"
	else:
		if player.carrying_player.spinning:
			player.sprite_speed_scale = 1
			return "Spin"
		if player.carrying_player.is_on_floor():
			return "Idle"
		elif player.velocity.y < 0:
			return "CarriedJump"
		else:
			return "CarriedFall"

func stop_yoshi_fly() -> void:
	yoshi_fly = false
	$"../../YoshiFlySFX".stop()
	player.yoshi.wings.play("Idle")

func summon_dash_particle() -> void:
	var node = DASH_START.instantiate()
	node.scale.x = player.facing_direction
	node.global_position = player.global_position
	GameManager.current_level.add_child(node)

func yoshi_earthquake() -> void:
	can_yoshi_stomp = false
	player.slam_attack()

func handle_yoshi_animation():
	if not player.turning and player.yoshi_animation_override == "":
		player.yoshi_animations.speed_scale = clamp(abs(player.velocity.x) / 40, 1, 999)
	else:
		player.yoshi_animations.speed_scale = 1
		return player.yoshi_animation_override
	if player.fluttering:
		player.yoshi_animations.speed_scale = 1
		return "Flutter"
	if player.crouching or player.sliding:
		return "Crouch"
	if player.is_on_floor():
		if abs(player.velocity.x) < 10:
			return "Idle"
		else:
			return "Move"
	else:
		if player.velocity.y < 0:
			return "Jump"
		else:
			return "Fall"

func exit() -> void:
	player.air_twirl_particles.emitting = false
	player.skid_particles.emitting = false
