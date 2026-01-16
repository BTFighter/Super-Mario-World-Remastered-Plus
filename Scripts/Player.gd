@icon("res://Assets/Sprites/Editor/Icons/Player.png")

class_name Player
extends CharacterBody2D

var current_animation := "Idle"
var player: Player = self

var yoshi_animation_override = ""

signal landed_on_ground

signal debug_settings_open

var can_land := false

var can_jump := true

var can_crush := true

var water_current_speed := Vector2.ZERO

var yoshi_perma_fly := false

var water_skimmed := false

var is_mega := false

var current_slope_height := 0.0

var invincible := false
var vardelta := 0.0
var can_step := false

var force_crouch := false

var spin_free := false
var can_turn := false
var facing_direction := 1

var riding_cloud: LakituCloud = null

var velocity_lerp := Vector2.ZERO

var sprinting := false

var power_script: PowerScript = null
@export var starting_direction := 1
var power_states: Array[PlayerState] = []

var combo_vals := [100, 200, 400, 800, 1000, 2000, 4000, 8000, 0]

var power_sprite_extras: Array[Node] = []
var pipe_travel_path: Curve2D = null
var pipe_travel_reverse := false
var pipe_travel_destination: PipeToPipeArea = null
var turning := false
@onready var powerup_extras_node: Node2D = $Sprite/PowerupExtras

var dead := false
var yoshi_tongue := false
var stand_yoshi_tongue := false

var yoshi_stomp := false
var carried := false
var can_pickup := true
var player_id := 0
@export var fast_death := false ## Makes the death really quick and dosent take away any lives, useful for Kaizo levels.
@onready var spawn_position := global_position
var character: CharacterResource = null
@onready var hold_position_animations: AnimationPlayer = $Sprite/HoldPosition/Animations

var fluttering := false

var no_wall_jump := false

var can_ride_yoshi := true
@onready var yoshi_tongue_node: Sprite2D = $Yoshi/Body/Head/Tongue
@onready var invicibility_glimmer: GPUParticles2D = $Particles/InvicibilityGlimmer
@onready var air_twirl_particles: GPUParticles2D = $Particles/AirTwirl

@onready var sprite: AnimatedSprite2D = $Sprite
var animation_override := ""
@onready var power_up_extras: Node2D = $Sprite/PowerupExtras
@onready var yoshi_animations: AnimationPlayer = $Yoshi/YoshiAnimations
@onready var yoshi_mario_point: Node2D = $Yoshi/MarioPoint
@onready var big_collision_box: CollisionShape2D = $BigCollisionBox

@onready var small_hitbox: CollisionShape2D = $Hitbox/SmallHitbox
@onready var big_hitbox: CollisionShape2D = $Hitbox/BigHitbox
@onready var yoshi_tongue_line: Line2D = $Yoshi/Body/Head/TongueLine
@onready var camera: Camera2D = $Camera
@onready var hitbox_area: Area2D = $Hitbox
@onready var liquid_checker: Node2D = $LiquidCheck

@onready var starman_timer: Timer = $Timers/StarmanTimer
@onready var jump_buffer: Timer = $Timers/JumpBuffer
@onready var state_machine: Node = $States


@onready var character_script: Node = $CharacterScript

@onready var hold_position: RemoteTransform2D = $Sprite/HoldPosition

@onready var carry_position: Marker2D = $CarryPosition
@onready var bubble_particle: GPUParticles2D = $Particles/Bubble

@onready var fire_ball_scene = preload("res://Instances/Prefabs/Projectiles/fireball.tscn")
@onready var small_power_state = preload("res://Resources/PlayerPowerUpState/Small.tres")
const FIRE_BREATH_SINGLE = preload("res://Instances/Prefabs/Projectiles/fire_breath_single.tscn")
const FIRE_BREATH = preload("res://Instances/Prefabs/Projectiles/fire_breath.tscn")
@onready var particles: Node = $Particles

@onready var skid_particles: GPUParticles2D = $Particles/Skid

@onready var skid_sfx: AudioStreamPlayer2D = $SkidSFX
@onready var ice_skid_sfx: AudioStreamPlayer2D = $IceSkidSFX

var star_points_goal := 0

var flip_panel: FlipPanel = null

var flags := {}

const climb_speed := 50
const climb_sprint := 80

const fast_climb_speed := 80
const fast_climb_sprint := 115

var riding_yoshi := false#

var swimming := false
var climbing := false

static var held_item_scene = null

var carry_height := 16.0

var spin_attacking := false
var spin_jumping := false

var yoshi_stored: Node = null
var yoshi_item: Node = null

@onready var yoshi_scene = preload("res://Instances/Prefabs/Interactables/yoshi.tscn")

var can_move := true
var can_damage := true
var can_hurt := true
var sliding := false
var current_power := ""
var jump_queued := false
var jumped := false
var run_jumped := false
var flying := false
var can_wall_climb := true
var yoshi_colour: Yoshi.colours

var metal_meter := 0.0

var climb_punch := false
var climb_area_velocity := Vector2.ZERO
var climb_x_lock := false
var climb_x_position := 0.0

var power_state: PlayerPowerUpState

var fire_attack := false
var fire_meter := 1.0
var can_fire := true

var ground_pound_land_timer := 1.0
var crouching := false
var running := false
var skidding := false
var spinning := false
var attacking := false
var holding := false
var ground_pounding := false
var held_object = null
var on_triangle_block := false
var yoshi_eaten := false ## has the player been eaten by another yoshi?
@export var camera_down := false ## Move the camera down, when the player is spawned in, useful for when the player starts higher up in the level.
@export var vertical_camera := false ## Adjusts the camera vertical margins, makes it more suitable for more vertical based levels.

@onready var starting_position := global_position

var timer_frozen := false
var can_dive := true
var can_bump := true
var is_star := false

var moving_up_slope := false

static var first_load := true

var in_shell := false
@onready var normal: Node = $States/Normal

var power_state_name := ""
@onready var ice_check: RayCast2D = $Raycasts/IceCheck
@onready var yoshi: Node2D = $Yoshi

signal level_finish_complete
signal on_jump

var gravity := 0.0

var p_meter := 0.0
const p_max := 112.0

const jump_gravity := 11.25
const fall_gravity := 22.5

var pipe_travel_speed := 200
var can_slip := true
var on_ice := false
var on_snow := false

var yoshi_berries_eaten := [0, 0, 0]

static var current_level_route: PlayerGhost 

var star_warning_played := false
var pipe_direction := ""
var direction := 1
var jump_combo := 0
var clone := false
var sprite_speed_scale := 1.0
var slope_direction := 1
var input_direction := 0
var velocity_direction := 1
var out_of_game := false
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = $OnScreenNotifier


enum Slopes{GRADUAL = 11, NORMAL = 23, STEEP = 45, VERY_STEEP = 67}

var state := ""

var score_save := 0
@onready var id_label_pos: Node2D = $CanvasLayer/Node2D
@onready var player_id_label: Label = $CanvasLayer/Node2D/PlayerIDLabel

var cosmic_route := []
var carrying_player: Player = null ## The player that is carrying this one!


func _enter_tree() -> void:
	pass

func _exit_tree() -> void:
	Yoshi.yoshi_amount -= 1
	CoopManager.player_amount -= 1
	for i in [CoopManager.alive_players, CoopManager.active_players, CoopManager.players]:
		i.erase(player_id)

func _ready() -> void:
	direction = starting_direction
	CoopManager.bubble_fly_away = false
	CoopManager.active_players[player_id] = self
	CoopManager.alive_players[player_id] = self
	set_character(CoopManager.player_characters[player_id])
	set_power_state(load(CoopManager.player_power_states[player_id]))
	riding_yoshi = CoopManager.player_yoshis[player_id]
	if GameManager.current_level_info != null:
		if GameManager.current_level_info.yoshi_allowed == false:
			riding_yoshi = false
	if riding_yoshi:
		Yoshi.yoshi_amount += 1
	CoopManager.player_spawned.emit()
	player_id_label.text = str(player_id + 1)
	player_id_label.modulate = CoopManager.player_colours[player_id]
	CoopManager.players[player_id] = self
	CoopManager.active_players[player_id] = self
	CoopManager.player_amount += 1
	if camera_down:
		var pos := global_position.y
		player.global_position.y += 128
		camera.align()
		global_position.y = pos
	if vertical_camera:
		camera.drag_top_margin = 0
		camera.drag_bottom_margin = 0.2
	yoshi_colour = CoopManager.yoshi_colours[player_id]
	timer_frozen = false
	if first_load:
		GameManager.time = 400
	first_load = false
	GameManager.yoshi_present = riding_yoshi
	if power_state == null:
		power_state = small_power_state
	if riding_yoshi:
		can_ride_yoshi = false
	show()
	if is_instance_valid(GameManager.current_level):
		camera.top_level = GameManager.current_level.lock_camera
		camera.limit_right = GameManager.current_level.camera_left_end_position
		camera.limit_top = GameManager.current_level.camera_top_end_position + 16
		if GameManager.checkpoint_level != "" and GameManager.current_level.scene_file_path == GameManager.checkpoint_level:
			self.global_position = GameManager.checkpoint_position
	CoopManager.coop_camera.global_position = global_position
	player.direction = starting_direction
	camera.global_position = global_position
	if CoopManager.get_first_any_player() != self:
		$CanvasLayer/MainHUD.queue_free()
	await get_tree().physics_frame
	if CoopManager.game_overed_players.has(player_id):
		remove_from_game()
	elif CoopManager.dead_players.has(player_id):
		await get_tree().create_timer(0.1, false).timeout
		bubble_respawn()
	spawn()

func spawn() -> void:
	pass

func _process(delta: float) -> void:
	var label_height = -39
	if power_state.hitbox_size == "Small":
		label_height = -30
	id_label_pos.global_position = get_global_transform_with_canvas().origin + (Vector2(0, label_height))
	player_id_label.visible = CoopManager.coop_enabled and CoopManager.splitscreen == false and CoopManager.players_connected > 1 and CoopManager.active_players.has(player_id) and not out_of_game
	if GameManager.time <= 0:
		time_up()
	$Sprite/Crown.visible = CoopManager.crown_player == player_id
	handle_yoshi(delta)
	MusicPlayer.is_yoshi = riding_yoshi
	GameManager.riding_yoshi = riding_yoshi
	if Input.is_action_just_pressed("debug_settings"):
		debug_settings_open.emit()
	if power_state:
		power_state_name = power_state.state_name
	if global_position.y > 112:
		die(true)
	particles.scale.x = direction
	handle_holding()
	handle_power_state()
	handle_carrying(delta)
	input_direction = sign(Input.get_axis(CoopManager.get_player_input_str("move_left", player.player_id), CoopManager.get_player_input_str("move_right", player.player_id)))
	
	if holding:
		if Input.is_action_just_released(CoopManager.get_player_input_str("run", player.player_id)):
			release_held_object()
	if is_star:
		if int(starman_timer.time_left) == 3:
			if star_warning_played == false:
				SoundManager.play_sfx(SoundManager.starman_low, self)
				star_warning_played = true
		material.set_shader_parameter("strength", 0.35)
	else:
		material.set_shader_parameter("strength", 0)
	invicibility_glimmer.emitting = is_star
	spin_attack_shape.set_deferred("disabled", not spin_attacking)
	if player.hitbox_area.monitoring:
		if player.hitbox_area.get_overlapping_areas().any(player.is_climbable) and not swimming and not climbing and not dead:
			if Input.is_action_pressed(CoopManager.get_player_input_str("move_up", player.player_id)) and not player.riding_yoshi and not holding:
				state_machine.transition_to("Climb")
	if Input.is_action_just_pressed("noclip") and OS.is_debug_build():
		if state_machine.state.name == "NoClip":
			state_machine.transition_to("Normal")
		else:
			state_machine.transition_to("NoClip")
@onready var yoshi_head: Sprite2D = $Yoshi/Body/Head
@onready var spin_attack_shape: CollisionShape2D = $AttackBoxes/SpinAttack/CollisionShape2D
@onready var yoshi_body: Sprite2D = $Yoshi/Body
@onready var yoshi_hack = Yoshi.new()

var yoshi_flying := false

func handle_yoshi(delta: float) -> void:
	yoshi.colour = yoshi_colour
	if riding_yoshi:
		yoshi.wings.visible = yoshi_flying
		yoshi.visible = sprite.visible
		sprite.global_position = yoshi_mario_point.global_position - Vector2(0, 8)
	else:
		yoshi.hide()
		sprite.position.y = -16
	if is_instance_valid(yoshi_stored):
		yoshi_head.frame = 4
	CoopManager.yoshi_colours[player_id] = yoshi_colour
	handle_yoshi_items(delta)
	if not turning:
		yoshi.scale.x = player.sprite.scale.x

func spawn_held_item() -> void:
	var item_node = held_item_scene
	item_node.global_position = global_position
	holding = true
	held_object = item_node
	held_object.moving = false
	held_object.player = self
	item_node.held = true
	GameManager.current_level.add_child(item_node)

func check_yoshi_item(item := yoshi_item) -> void:
	player.yoshi_animation_override = ""
	player.animation_override = ""
	yoshi_tongue = false
	stand_yoshi_tongue = false
	disable_yoshi_abilities()
	if item == null:
		return
	if item is Player:
		yoshi_player_swallow(yoshi_item)
	if item is FlashingShell:
		yoshi_flying = true
		yoshi_stomp = true
	if item is KoopaShell or item is KoopaTroopa:
		if item.colour == 3 or yoshi_colour == 2:
			yoshi_flying = true
		if item.colour == 2 or yoshi_colour == 3:
			yoshi_stomp = true
	if item is PowerUp or item is Coin or item is PhysicsCoin:
		item.global_position = global_position - Vector2(0, 16)
	
	elif item is Enemy and item.can_hurt:
		match item.yoshi_behavior:
			"Swallow":
				item.queue_free()
				yoshi_swallow_item()
			"Spit":
				yoshi_stored = item.duplicate()
				item.queue_free()
	elif item is YoshiBerry:
		yoshi_berry_eat(item.colour)
	
	elif item is HeldObject:
		yoshi_stored = item.duplicate()
		item.queue_free()
	yoshi_item = null
@onready var head_animations: AnimationPlayer = $Yoshi/Body/Head/HeadAnimations

func disable_yoshi_abilities() -> void:
	if not yoshi_perma_fly:
		yoshi_flying = false
	yoshi_stomp = false

func yoshi_player_swallow(yoshi_player: Player) -> void:
	yoshi_stored = yoshi_player
	yoshi_player.remove_from_game()

func yoshi_berry_eat(colour := 0) -> void:
	yoshi_item.queue_free()
	add_yoshi_berry(colour)
	yoshi_swallow_item()
	get_tree().paused = true
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = false

func set_character(char: CharacterResource) -> void:
	character = char
	if char.character_script != null:
		character_script.queue_free()
		character_script = Node.new()
		character_script.set_script(char.character_script)
		add_child(character_script)

func yoshi_spit_item() -> void:
	if is_instance_valid(yoshi_stored) == false:
		return
	if riding_yoshi == false:
		yoshi_stored == null
		return
	if yoshi_stored is HeldObject:
		if yoshi_stored.spit_item_override != null:
			yoshi_stored = yoshi_stored.spit_item_override.instantiate()
	if yoshi_stored is Enemy:
		if yoshi_stored.spit_item != null:
			var shell_colour := 0
			if yoshi_stored is KoopaTroopa:
				shell_colour = yoshi_stored.colour
			yoshi_stored = yoshi_stored.spit_item.instantiate()
			if yoshi_stored is KoopaShell:
				yoshi_stored.colour = shell_colour
				if yoshi_colour == 1:
					if power_state.state_name == "Fire":
						yoshi_stored = FIRE_BREATH.instantiate()
					else:
						yoshi_stored = FIRE_BREATH_SINGLE.instantiate()
	if yoshi_stored is Player:
		yoshi_stored.yoshi_eaten = false
		yoshi_stored.add_to_game()
		yoshi_stored.global_position = global_position - Vector2(0, 4)
		yoshi_stored.state_machine.transition_to("Thrown")
	else:
		yoshi_stored.global_position = global_position + Vector2(16 * direction, -16)
		if test_move(global_transform, Vector2(player.direction, 0)):
			yoshi_stored.global_position = global_position - Vector2(0, 16)
	if yoshi_stored is Player:
		yoshi_stored.out_of_game = false
	else:
		get_parent().add_child(yoshi_stored)
	$YoshiFlySFX.stop()
	disable_yoshi_abilities()
	yoshi_stored.direction = direction
	head_animations.play("Spit")
	if yoshi_stored is CharacterBody2D:
		yoshi_stored.velocity.x = 200 * direction
	if yoshi_stored is HeldObject:
		yoshi_stored.kick_forward()
		yoshi_stored.velocity += player.velocity
		yoshi_stored.moving = true
	if yoshi_stored is Shell:
		yoshi_stored.shell_moving = true
	SoundManager.play_sfx(SoundManager.yoshi_spit, self)
	yoshi_stored = null

func add_to_game() -> void:
	CoopManager.active_players[player_id] = self
	CoopManager.alive_players[player_id] = self
	show()
	out_of_game = false

func yoshi_swallow_item() -> void:
	player.vibrate_controller(0.6)
	yoshi_stored = null
	yoshi_item = null
	SoundManager.play_sfx(SoundManager.yoshi_gulp, self)
	SoundManager.play_sfx(SoundManager.coin, self)
	GameManager.add_coin(1)
	head_animations.play("Swallow")

func yoshi_use_tongue() -> void:
	if yoshi_tongue:
		return
	if yoshi_stored != null:
		yoshi_spit_item()
		return
	turning = false
	if player.input_direction != 0:
		player.direction = player.input_direction
		player.facing_direction = player.input_direction
	else:
		direction = player.facing_direction
	yoshi.scale.x = player.direction
	SoundManager.play_sfx(SoundManager.yoshi_eat, player)
	yoshi_tongue = true
	yoshi_animations.play("RESET")
	player.facing_direction = direction
	yoshi_animations.stop()
	player.animation_override = "YoshiPunch"
	player.yoshi_animation_override = "Tongue"

func yoshi_mount(_yosh: Yoshi) -> void:
	if can_ride_yoshi == false:
		return
	player.vibrate_controller(0.8)
	if holding:
		release_held_object(false)
	if carrying:
		throw()
	disable_yoshi_abilities()
	CoopManager.player_yoshis[player_id] = true
	Yoshi.yoshi_amount += 1
	velocity = Vector2.ZERO
	var valid_state := true
	if ["LevelFinish", "FinishWait", "Freeze"].has(state_machine.state.name) == false:
		state_machine.transition_to("Freeze", {"Gravity" = true})
		yoshi_animations.play("Crouch")
	else:
		valid_state = false
	velocity.x = 0
	riding_yoshi = true
	can_ride_yoshi = false
	CoopManager.yoshi_colours[player_id] = yoshi_colour
	if yoshi_stored != null:
		check_yoshi_item(yoshi_stored)
	await get_tree().create_timer(0.1, false).timeout
	if valid_state:
		state_machine.transition_to("Normal")

func yoshi_hurt() -> void:
	SoundManager.play_sfx(SoundManager.yoshi_hurt, self)
	disable_damage()
	yoshi_dismount(true)

func yoshi_dismount(hurt := false) -> void:
	if is_instance_valid(yoshi_stored):
		if yoshi_stored is Player:
			yoshi_spit_item()
	if is_instance_valid(yoshi_item):
		if yoshi_item is Enemy:
			yoshi_item.is_yoshi_item = false
	CoopManager.player_yoshis[player_id] = false
	riding_yoshi = false
	yoshi_item = null
	disable_yoshi_abilities()
	animation_override = ""
	yoshi_item = null
	fluttering = false
	yoshi_animation_override = ""
	yoshi_tongue = false
	global_position.y -=8
	Yoshi.yoshi_amount -= 1
	spawn_dummy_yoshi(hurt)
	await get_tree().create_timer(0.5, false).timeout
	can_ride_yoshi = true

func spawn_dummy_yoshi(damaged := false) -> void:
	var yoshi_node = yoshi_scene.instantiate()
	yoshi_node.global_position = global_position
	yoshi_node.first_ride = false
	yoshi_node.colour = yoshi_colour
	yoshi_node.direction = facing_direction
	yoshi_node.yoshi_stored = yoshi_stored
	get_parent().call_deferred("add_child", (yoshi_node))
	await get_tree().process_frame
	if damaged:
		yoshi_node.state_machine.transition_to("Panic")


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_secret"):
		state_machine.transition_to("NoClip")
	if Input.is_action_just_pressed("debug_clear"):
		state_machine.transition_to("AnimationTest")
	handle_camera(delta)
	can_turn = riding_yoshi or holding or carrying
	if hitbox_area.monitoring:
		can_jump = not hitbox_area.get_overlapping_areas().any(func(area): return area is JumpDisableArea)
		for i in hitbox_area.get_overlapping_areas():
			if i is JumpDisableArea:
				player.jump_queued = false
				if i.player_slow:
					player.velocity.x = clamp(player.velocity.x, -50, 50)
	if player.is_on_floor() and (not sliding and not is_star):
		jump_combo = 0
	vardelta = delta
	CoopManager.player_power_states[player_id] = power_state.resource_path
	check_for_collisions()
	if get_floor_normal().x < 0:
		slope_direction = -1
	elif get_floor_normal().x > 0:
		slope_direction = 1
	elif is_equal_approx(get_floor_normal().x, 0):
		slope_direction = 0
	moving_up_slope = player.direction == -slope_direction
	velocity_direction = sign(player.velocity.x)
	set_collision_mask_value(19, state_machine.state.name == "Climb")
	$Raycasts/WallJumpWall.target_position.x = 4 * direction
	no_wall_jump = $Raycasts/WallJumpWall.is_colliding()
	if is_mega:
		for i in hitbox_area.get_overlapping_bodies():
			if i is Block:
				i.shatter()
	if player.is_on_ceiling() and player.is_on_floor() == false and can_bump:
		bump_ceiling()
	elif player.is_on_floor():
		can_bump = true
	if is_on_floor():
		can_dive = true
		can_wall_climb = true
	if can_move:
		move_and_slide()
		#move_and_collide(velocity)
	velocity_lerp = lerp(velocity_lerp, velocity, delta * 10)
	on_ice = ice_check.is_colliding()

var carrying := false


func bump_ceiling() -> void:
	can_bump = false
	vibrate_controller(0.5)
	play_sfx("bump")

func refresh_hitbox() -> void:
	hitbox_area.set_deferred("monitoring", false)
	hitbox_area.set_deferred("monitorable", false)
	for i in 2:
		await get_tree().physics_frame
	hitbox_area.set_deferred("monitorable", true)
	hitbox_area.set_deferred("monitoring", true)

func check_for_collisions() -> void:
	var direction_strings = ["Up", "Down", "Left", "Right"]
	var direction_vectors = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var checks := 0
	if carried:
		return
	for i in 4:
		var current_string: String = direction_strings[i]
		var current_vector: Vector2 = direction_vectors[i]
		var collision = move_and_collide((current_vector / 2) + (velocity * vardelta), true, 0.08)
		if is_instance_valid(collision):
			if collision.get_collider() is Block:
				if current_vector.dot(-collision.get_normal()) > 0.25:
					if is_valid_collision(collision, current_string):
						collision.get_collider().block_hit(current_string)
						return

func is_valid_collision(collision: KinematicCollision2D, direction_string := "") -> bool:
	var valid := false
	var collider = collision.get_collider()
	if collider is Block:
		collider.player = self
		if (direction_string == "Left" or direction_string == "Right") and collider.enable_side_hits:
			if spin_attacking:
				valid = true
		elif direction_string == "Down" and collider.enable_ground_pounds:
			if collider.can_hit and ground_pounding:
				if power_state.hitbox_size == "Regular":
					collider.ground_pounded.emit()
				valid = true
				collider.on_ground_pound(self)
		elif direction_string == "Up":
			if velocity.y < 100:
				valid = true
	return valid

@onready var carry_collision: CollisionShape2D = $CarryCollision


func handle_carrying(delta: float) -> void:
	var big_target := false
	carry_collision.set_deferred("disabled", not carrying)
	if not carrying:
		return
	carry_height = 24
	if is_instance_valid(carry_target) == false:
		carrying = false
		carried = false
		return
	if carry_target is Player:
		carry_target.direction = direction
		carry_target.facing_direction = direction
		carry_target.velocity = velocity
	if power_state.hitbox_size == "Regular":
		carry_height += 8
	if carry_target is Player:
		if carry_target.power_state.hitbox_size == "Regular":
			carry_height += 30
		else:
			carry_height += 22
	if carry_target is IceBlock:
		carry_height += carry_target.size.y * 16
	carry_height -= 16
	carry_collision.shape.size.y = carry_height
	carry_collision.position.y = -(float(carry_height) / 2)
	if is_instance_valid(carry_target) == false:
		carry_let_go()
		return
	if carry_target is Player:
		big_target = carry_target.power_state.hitbox_size == "Regular"
		carry_target.velocity = velocity
	if power_state.hitbox_size == "Regular":
		carry_position.position.y = -24
	else:
		carry_position.position.y = -16
	if carry_target is CarryItem:
		carry_target.carried = true
	carry_target.direction = direction
	if is_instance_valid(carry_target):
		carry_target.global_position = carry_position.global_position
	if Input.is_action_just_released(CoopManager.get_player_input_str("run", player_id)):
		throw()

func carry_let_go() -> void:
	if carrying == false:
		return
	carrying = false
	if is_instance_valid(carry_target) == false:
		carry_target = null
		return
	carry_target.carried = false
	if carry_target is Player:
		carry_target.carrying_player = null
	carry_target.velocity.x = 50 * -direction
	carry_target.global_position += Vector2(-8 * direction, -2)
	carry_target = null

func throw() -> void:
	if carry_target is CarryItem:
		carry_target.throw()
	if carry_target is Player:
		carry_target.set_collision_layer_value(1, true)
		carry_target.set_collision_mask_value(1, true)
		if carry_target.state_machine.state.name != "PBalloon":
			carry_target.state_machine.transition_to("Thrown")
		carry_target.carrying_player = null
		carry_target.carried = false
		carry_target.velocity.x = 200 * direction
	carry_target.velocity.x += abs(velocity.x) * direction
	carry_target.global_position.y += 4
	carry_target.global_position.x += 2 * direction
	carrying = false
	animation_override = "Throw"
	SoundManager.play_sfx(SoundManager.throw, self)
	carry_target.velocity.y = 0
	carry_target = null
	await get_tree().create_timer(0.25, false).timeout
	animation_override = ""

func release_held_object(can_kick := true) -> void:
	spinning = false
	hold_position_animations.play("RESET")
	await get_tree().physics_frame
	if is_instance_valid(held_object):
		held_object.velocity.x += (velocity.x / 1.25)
		hold_position.remote_path = ""
		if held_object.is_on_wall() or player.is_on_wall():
			held_object.global_position.x = global_position.x
		else:
			var dir := player.direction
			if player.input_direction != 0:
				dir = player.input_direction
			held_object.global_position.x = global_position.x + (8 * dir)
		held_object.let_go()
		if Input.is_action_pressed(CoopManager.get_player_input_str("move_down", player_id)):
			held_object_let_go()
			held_object.velocity.y = 0
		elif can_kick:
			held_object_kick()
	can_pickup = false
	holding = false
	held_item_scene = null
	held_object = null
	await get_tree().create_timer(0.1, false).timeout
	can_pickup = true

func held_object_kick() -> void:
	if is_instance_valid(held_object):
		held_object.kick_object()
		if held_object.is_on_wall() or player.is_on_wall():
			held_object.global_position.x = global_position.x
	vibrate_controller(0.5)
	play_kick_animation()

func play_kick_animation() -> void:
	await get_tree().physics_frame
	if holding or carrying or riding_yoshi:
		return
	animation_override = "Kick"
	await get_tree().create_timer(0.2, false).timeout
	animation_override = ""

func held_object_let_go() -> void:
	pass

func time_up() -> void:
	die()

var carry_target: Node2D = null
const GOAL_POST_POWER_REWARD = preload("res://Instances/Parts/goal_post_power_reward.tscn")

func level_finish_powerup_reward() -> void:
	if riding_yoshi:
		if is_instance_valid(yoshi_stored) == false:
			return
		if yoshi_stored is HeldObject:
			GameManager.add_life(1, global_position)
			yoshi_swallow_item()
			return
	if not holding:
		return
	var node = GOAL_POST_POWER_REWARD.instantiate()
	node.global_position = held_object.global_position
	node.power_up = power_state
	node.is_one_up = held_object.reward_life
	SoundManager.play_sfx(SoundManager.magic, self)
	if power_state.power_down == null:
		node.power_up = load(CoopManager.BIG)
	ParticleManager.summon_particle(ParticleManager.PUFF_SPR, held_object.global_position)
	held_object.queue_free()
	add_sibling(node)

func power_up(power: PlayerPowerUpState) -> void:
	if power == null:
		return
	player.vibrate_controller(1, 0.2)
	GameManager.add_score(1000, true, self.global_position)
	if power.power_sfx_override:
		SoundManager.play_sfx(power.power_sfx_override, self)
	else:
		play_sfx("powerup")
	if is_mega:
		GameManager.add_item(power)
		return
	if power == power_state or power.power_tier < power_state.power_tier:
		GameManager.add_item(power)
		return
	if power.power_tier <= power_state.power_tier:
		GameManager.add_item(power_state)
	await power_up_animation(power_state, power)
	if state_machine.state.power_state:
		state_machine.transition_to("Normal")
	set_power_state(power)
	await get_tree().create_timer(0.5, false).timeout
	can_crush = true

func is_carriable(area: Area2D) -> bool:
	var can_carry := false
	var node = area.owner
	if node is CarryItem:
		can_carry = true
	if node is Player and node != self:
		if node.riding_yoshi == false:
			can_carry = true
	if can_carry:
		carry_target = node
	return can_carry

func power_up_animation(old_power, new_power) -> void:
	can_crush = false#
	var grow_animation := false
	if new_power.transform_animation:
		play_power_transform_animation()
		return
	var old_frames = load("res://Resources/PlayerSpriteFrames/" + character.character_name + "/" + old_power.sprite_frame_name + ".tres")
	var new_frames = load("res://Resources/PlayerSpriteFrames/" + character.character_name + "/" + new_power.sprite_frame_name + ".tres")
	if is_instance_valid(new_frames):
		if new_frames.has_animation(sprite.animation) == false:
			sprite.animation = "Fall"
			current_animation = "Fall"
	await get_tree().process_frame
	if old_power.hitbox_size != new_power.hitbox_size:
		grow_animation = true
		sprite.process_mode = Node.PROCESS_MODE_ALWAYS
		sprite.speed_scale = 1
		sprite_speed_scale = 1
		sprite.play("Grow")
	sprite.show()
	get_tree().paused = true
	if not grow_animation:
		for i in 4:
			sprite.sprite_frames = old_frames
			await get_tree().create_timer(0.07).timeout
			sprite.sprite_frames = new_frames
			await get_tree().create_timer(0.07).timeout
	else:
		sprite.sprite_frames = old_frames
		await get_tree().create_timer(0.3, true).timeout
		sprite.sprite_frames = new_frames
		sprite.stop()
		sprite.play("Grow")
		await get_tree().create_timer(0.4, true).timeout
	current_animation = "Idle"
	sprite.process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().paused = false

func bounce_off() -> void:
	vibrate_controller(0.5)
	player.fluttering = false
	if Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
		player.velocity.y = -330
	else:
		player.velocity.y = -180

func spin_bounce_off(enemy := false) -> void:
	vibrate_controller(1)
	if Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)) or Input.is_action_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)):
		player.velocity.y = -300
		player.gravity = player.jump_gravity
	elif enemy:
		player.velocity.y = -30
		player.gravity = player.fall_gravity
	else:
		player.velocity.y = -200
		player.gravity = player.fall_gravity

func bounce_point_rel(point_position := Vector2.ZERO, score := true) -> void:
	player.fluttering = false
	SoundManager.play_sfx(SoundManager.stomp, self)
	var player_angle = point_position.angle_to_point(global_position)
	velocity.x = Vector2.from_angle(player_angle).x * 200
	summon_flash_particle()
	if Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
		player.velocity.y = -300
		player.gravity = player.jump_gravity
	else:
		player.velocity.y = -200

func carry_grab_collision_check(height := 32) -> bool:
	return test_move(global_transform, Vector2.UP * (height - 6), null, -1)

func carry_grab(target: Node2D) -> void:
	if riding_yoshi:
		return
	if holding:
		return
	if carrying:
		return
	if carried:
		return
	var height_check := 8
	if power_state.hitbox_size == "Regular":
		height_check += 8
	if target is Player:
		if target.power_state.hitbox_size == "Regular":
			height_check += 30
		else:
			height_check += 24
	height_check -= 16
	state_machine.transition_to("CarryCrouch")
	if carry_target is CarryItem or carry_target is Player:
		carry_target.carried = true
	if carry_target is Player:
		carry_target.carrying_player = self
	carrying = true

@onready var flash = preload("res://Instances/Parts/flash_particle.tscn")

func summon_flash_particle(offset := Vector2.ZERO) -> void:
	var node = flash.instantiate()
	node.global_position = player.global_position + offset
	player.add_sibling(node)

func damage() -> void:
	if can_hurt == false:
		return
	if invincible:
		return
	if riding_yoshi:
		yoshi_hurt()
		return
	if power_state.power_down == null:
		die()
		return
	if yoshi_eaten:
		return
	if power_state == small_power_state:
		die()
		return
	
	vibrate_controller(1)
	sprite.show()
	can_slip = true
	disable_damage()
	if has_flag("CapeFlying"):
		power_script.spin_out()
		return
	if GameManager.reserved_item:
		if power_state.power_down.power_tier < GameManager.reserved_item.power_tier and SettingsManager.settings_file.auto_item_drop:
			GameManager.drop_current_held_item()
	if state_machine.state.power_state:
		state_machine.transition_to("Normal")
	play_sfx("powerdown")
	if SettingsManager.settings_file.player_damage_style == 0:
		await power_up_animation(power_state, power_state.power_down)
		set_power_state(power_state.power_down)
	else:
		await power_up_animation(power_state, load(CoopManager.SMALL))
		set_power_state(load(CoopManager.SMALL))

func die(force := false) -> void:
	if dead:
		return
	if can_hurt == false and force == false:
		return
	if state_machine.state.name == "NoClip":
		return
	if yoshi_eaten:
		return
	if carried:
		carrying_player.carry_let_go()
	vibrate_controller(1)
	release_held_object(false)
	carry_let_go()
	if riding_yoshi:
		yoshi_dismount(true)
	if is_instance_valid(held_object):
		held_object.let_go()
	timer_frozen = true
	dead = true
	GameManager.run_states = {}
	
	state_machine.transition_to("Dead")
@onready var flash_animation_player: AnimationPlayer = $Sprite/Flash

func bubble_respawn() -> void:
	add_to_game()
	global_position = get_viewport().get_camera_2d().get_screen_center_position() + Vector2(randi_range(-240, 240), randi_range(-120, 120) / 2)
	animation_player.play("BubbleGrow")
	state_machine.transition_to("BubbleRevive")
	CoopManager.alive_players.erase(player_id)
	CoopManager.game_overed_players.erase(player_id)

func set_power_state(power: PlayerPowerUpState) -> void:
	power_state = power
	for i in power_states:
		i.queue_free()
	for i in power_sprite_extras:
		i.queue_free()
	power_sprite_extras = []
	if is_instance_valid(power_script):
		power_script.queue_free()
	await get_tree().process_frame
	for i in power.sprite_extras:
		if character.power_sprite_extra_replaces.has(i):
			create_power_sprite_extra(character.power_sprite_extra_replaces[i])
		else:
			create_power_sprite_extra(i)
	if is_instance_valid(power.power_script):
		create_power_script_node(power)
	if state_machine.state.power_state:
		var state_del = state_machine.state
		state_del.queue_free()
		state_machine.transition_to("Normal")
	current_animation = "Idle"
	sprite.stop()
	sprite.play()

func vibrate_controller(strength := 0.5, duration := 0.1) -> void:
	Input.start_joy_vibration(CoopManager.player_device_ids[player_id], strength, strength, duration)

func disable_damage(animation := true) -> void:
	can_hurt = false
	if animation:
		play_flash_animation()
	await get_tree().create_timer(2, false).timeout
	refresh_hitbox()
	can_hurt = true

func play_power_transform_animation() -> void:
	get_tree().paused = true
	sprite.hide()
	ParticleManager.summon_particle(ParticleManager.PUFF_SPR, global_position - Vector2(0, 16))
	await get_tree().create_timer(0.5, true).timeout
	current_animation = "Idle"
	sprite.show()
	get_tree().paused = false

func play_flash_animation() -> void:
	for i in 20:
		sprite.show()
		await get_tree().create_timer(0.05, false).timeout
		sprite.hide()
		await get_tree().create_timer(0.05, false).timeout
	sprite.show()

func water_enter(current_speed) -> void:
	in_shell = state_machine.state.name == "ShellSlide"
	water_current_speed = current_speed
	if in_shell:
		return
	if power_state.can_water_damage:
		damage()
	elif state_machine.state.can_change and state_machine.state.name != "Pipe":
		state_machine.transition_to("Swim", {current = current_speed})

func water_exit() -> void:
	if in_shell or CoopManager.pipe_exiting or out_of_game or state_machine.state.name != "Swim":
		return
	if Input.is_action_pressed(CoopManager.get_player_input_str("move_up", player.player_id)):
		velocity.y = -300
	else:
		velocity.y = -150
	state_machine.transition_to("Normal")

func enter_pipe(pipe_direction := "Down", pipe: Node = null) -> void:
	if state_machine.state.name == "Pipe":
		return
	carry_let_go()
	state_machine.transition_to("Pipe", {"Enter" = true, "Direction" = pipe_direction, "GroundPound" = ground_pounding, "Pipe" = pipe})

func exit_pipe(pipe: Node, pipe_direction := "Down") -> void:
	if state_machine.state.name == "Pipe":
		return
	add_to_game()
	sprite.hide()
	if pipe.cannon_exit:
		state_machine.transition_to("Freeze")
		global_position = pipe.global_position
		reset_physics_interpolation()
		sprite.show()
		GameManager.can_pause = true
		state_machine.transition_to("Normal")
		player.vibrate_controller(1, 0.25)
		p_meter = p_max
		velocity.x = 480
		velocity.y = -480
		sprinting = true
		play_sfx("bullet")
		running = true
	else:
		state_machine.transition_to("Pipe", {"Exit" = true, "Direction" = pipe_direction, "Pipe"=pipe})

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

func super_star() -> void:
	star_warning_played = false
	MusicPlayer.super_star()
	invincible = true
	is_star = true
	starman_timer.stop()
	starman_timer.start()
	await starman_timer.timeout
	GameManager.star_ended.emit()
	invincible = false
	is_star = false

var sprite_frame_dir := ""

func handle_power_state() -> void:
	sprite_frame_dir = ("res://Resources/PlayerSpriteFrames/" + character.character_name + "/" + power_state.sprite_frame_name + ".tres")
	sprite.sprite_frames = load(sprite_frame_dir)
	sprite.speed_scale = sprite_speed_scale
	sprite_speed_scale = clamp(sprite_speed_scale, 1, 99999)
	for i in power_sprite_extras:
		if character.power_sprite_extra_offsets.has(i.extra_name):
			i.position = character.power_sprite_extra_offsets[i.extra_name]
	if sprite.sprite_frames != null:
		if sprite.sprite_frames.has_animation(current_animation):
			if sprite.animation != current_animation:
				sprite.play(current_animation)
	
	var big_collision_enabled := false
	
	if riding_yoshi:
		big_collision_enabled = not crouching
	elif not crouching:
		big_collision_enabled = power_state.hitbox_size == "Regular"
	
	big_collision_box.set_deferred("disabled", not big_collision_enabled)
	big_hitbox.set_deferred("disabled", not big_collision_enabled)
	
	var corner_wrap := false
	if not crouching:
		if not is_on_floor():
			corner_wrap = true
	for i in [$CornerSlideL, $CornerSlideR]:
		i.position.y = -30 if power_state.hitbox_size == "Regular" else -24
		i.set_deferred("disabled", not corner_wrap)

func play_turn_animation(new_direction := 1) -> void:
	turning = true
	player.yoshi_animations.stop(false)
	if SettingsManager.sprite_settings.yoshi == 0:
		player.yoshi_animations.play("TurnClassic")
	else:
		player.yoshi_animations.play("Turn")
	if player.riding_yoshi:
		await get_tree().create_timer(0.2, false).timeout
	else:
		await get_tree().create_timer(0.1, false).timeout
	player.facing_direction = new_direction
	turning = false

func create_power_script_node(power: PlayerPowerUpState) -> void:
	for i in power.states:
		create_player_state(i)
	var node = PowerScript.new()
	var script = power.power_script
	if character.power_state_script_replace.has(power.power_script):
		script = character.power_state_script_replace[power.power_script]
	node.set_script(script)
	add_child(node)
	power_script = node

func create_player_state(player_state: Script) -> void:
	state_machine.add_state(player_state)

func create_power_sprite_extra(scene: PackedScene) -> void:
	var node = scene.instantiate()
	power_up_extras.add_child(node)
	if character.power_sprite_extra_offsets.has(node.extra_name):
		node.position += character.power_sprite_extra_offsets[node.extra_name]
	node.player = self
	power_sprite_extras.append(node)

func is_climbable(area: Area2D) -> bool:
	return area is Climbable

func spiky_jump() -> void:
	player.vibrate_controller(0.6)
	if Input.is_action_pressed(CoopManager.get_player_input_str("jump", player_id))  or Input.is_action_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)):
		velocity.y = -300
		gravity = jump_gravity
	else:
		velocity.y = -200
	summon_flash_particle()
	SoundManager.play_sfx(SoundManager.stomp, self)

func pickup_object(object) -> void:
	if holding:
		return
	if carrying:
		return
	if carried:
		return
	
	if riding_yoshi:
		return
	if can_pickup == false:
		return
	holding = true
	held_object = object
	held_object.player = self
	held_object.velocity = Vector2.ZERO
	held_object.picked_up.emit()
	hold_position_animations.play("RESET")
	object.held = true
	animation_override = "HoldCrouch"
	await get_tree().create_timer(0.1, false).timeout
	animation_override = ""

func remove_from_game() -> void:
	carry_let_go()
	CoopManager.player_amount -= 1
	out_of_game = true
	CoopManager.active_players.erase(player_id)
	CoopManager.alive_players.erase(player_id)
	state_machine.transition_to("Freeze")
	hide()

func handle_holding() -> void:
	if crouching or power_state.hitbox_size == "Small":
		hold_position.position.y = 16
	else:
		hold_position.position.y = 14
	if player.spinning:
		hold_position_animations.play("Spin")
	elif hold_position_animations.current_animation != "":
		hold_position_animations.stop()
	player.holding = is_instance_valid(held_object)
	if player.current_animation == "FaceForward":
		player.hold_position.position.x = 0
		player.hold_position.z_index = 1
	else:
		player.hold_position.position.x = 8
	if is_instance_valid(player.held_object):
		player.held_object.held = true
		hold_position.remote_path = hold_position.get_path_to(player.held_object)
		if player.input_direction != 0:
			player.held_object.direction = player.input_direction
		if player.turning:
			player.held_object.z_index = 1
		else:
			player.held_object.z_index = -1
		player.held_object.z_index += player.z_index
		player.held_object.z_index += hold_position.z_index * 2
	else:
		hold_position.remote_path = ""
func level_finish() -> void:
	if riding_cloud != null:
		riding_cloud.queue_free()

func boss_defeated(cutscene := "", primary := false) -> void:
	carry_let_go()
	state_machine.transition_to("LevelFinish", {"Secret" = false, "Bonus" = false, "Boss" = true, "Level" = cutscene, "Cutscene" = primary})
	GameManager.run_states = {}

func has_flag(flag_name := "") -> bool:
	var valid := false
	if flags.has(flag_name):
		return flags.get(flag_name)
	return false

func add_jump_combo() -> void:
	play_sfx("stomp_attack", 1 + (float(jump_combo) / 10))
	jump_combo += 1
	jump_combo = clamp(jump_combo, 0, combo_vals.size() - 1)
	if jump_combo >= 8:
		SoundManager.play_sfx(SoundManager.one_up, self)
		GameManager.add_life(1, global_position)
		return
	GameManager.add_score(combo_vals[jump_combo], true, global_position)


func _on_jump_buffer_timeout() -> void:
	jump_queued = false


func game_over() -> void:
	GameManager.game_over()
@onready var step_collision: CollisionShape2D = $StepCollision
@onready var step_collision_2: CollisionShape2D = $StepCollision2


@onready var collision_check: StaticBody2D = $CrushCollisionCheck

func crush_check() -> void:
	if CoopManager.pipe_exiting or out_of_game:
		return
	if can_jump == false:
		return
	if player.is_on_floor():
		force_crouch_check()
	if $CrushCheck.test_move(global_transform, Vector2.ZERO, null, 0):
		if (player.is_on_floor() == false and player.is_on_wall() == true and player.is_on_ceiling() == false):
			crushed()
		elif (player.is_on_floor() == false and player.is_on_wall() == false and player.is_on_ceiling() == true):
			crushed()

func force_crouch_check() -> void:
	force_crouch = $ForceCrouchCheck.test_move($ForceCrouchCheck.global_transform, Vector2.UP * 2) and power_state.hitbox_size == "Regular"

func run_cast_crush_check(cast: RayCast2D) -> bool:
	if cast.is_colliding():
		if cast.get_collision_normal().x == 0 or cast.get_collision_normal().x == 1:
			if cast.get_collision_normal().y == 0 or cast.get_collision_normal().y == 1:
				return true
	return false

func run_crush_check(vector := Vector2.UP) -> bool:
	return test_move(global_transform, vector)

func crushed() -> void:
	die(true)

func lava_enter() -> void:
	die()


func is_valid_yoshi_item_types(node: Node) -> bool: #i fucking hate my life.
	return node is Coin or (node is Enemy and node.yoshi_behavior != "None") or node is PowerUp or (node is HeldObject and node.yoshi_can_eat) or node is YoshiBerry or (node is Player and not node == self and node.riding_yoshi == false and node.holding == false and node.carrying == false) or node is PhysicsCoin

func handle_yoshi_items(_delta: float) -> void:
	if not yoshi_item:
		return
	if yoshi_item is Player:
		yoshi_item.yoshi_eaten = true
	yoshi_item.global_position = self.yoshi_tongue_node.global_position

func handle_turn_stuff(yoshi := true, hold := true) -> void:
	if player.holding:
		if hold == false:
			player.facing_direction = player.input_direction
			return
	if player.riding_yoshi:
		if yoshi == false:
			player.facing_direction = player.input_direction
			return
	if not player.yoshi_tongue and not player.turning:
		if player.input_direction != 0:
			if not can_turn:
				player.facing_direction = player.input_direction
			elif player.facing_direction != player.input_direction and not player.turning:
				player.play_turn_animation(player.input_direction)
		player.sprite.scale.x = player.facing_direction

func yoshi_tongue_hit(area: Area2D) -> void:
	if is_instance_valid(yoshi_item) or yoshi_tongue == false:
		return
	if is_valid_yoshi_item_types(area.owner):
		yoshi_item = area.owner
		if yoshi_item is Enemy:
			yoshi_item.on_yoshi_tongue_grab()
			yoshi_item.is_yoshi_item = true
		if stand_yoshi_tongue:
			yoshi_animation_override = "StandTongueEat"
		else:
			yoshi_animation_override = "TongueEat"
		yoshi_tongue_eat_animation()

func yoshi_tongue_eat_animation() -> void:
	var tween = create_tween()
	tween.set_trans(tween.TRANS_CIRC)
	tween.tween_property(yoshi_tongue_node,"position:x", 14, 0.3)


func _on_fence_punch_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Enemy:
		area.owner.damage()
		SoundManager.play_sfx(SoundManager.kick, self)

@onready var spin_attack_hitbox: Area2D = $AttackBoxes/SpinAttack

func _on_spin_attack_area_entered(area: Area2D) -> void:
	if area.owner is Enemy:
		var enemy = area.owner as Enemy
		if enemy.can_cape_damage:
			enemy.player = self
			enemy.melee_attack()
			return
	elif area.owner is Shell:
		var shell = area.owner as Shell
		shell.velocity.x = 0
		shell.velocity.y = -400
		shell.moving = false
		shell.shell_moving = false
		shell.can_pickup = true
		shell.flipped = true



func screenshot() -> void:
	DirAccess.make_dir_recursive_absolute("user://Screenshots")
	await get_tree().physics_frame
	var capture = get_viewport().get_texture().get_image()
	var time = Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(), false)
	time = time.replace(":", "-")
	var file_name = "user://Screenshots/" + time + ".png"
	capture.save_png(file_name)
	SoundManager.play_ui_sound(SoundManager.correct)
	
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_hitbox_area_entered(area: Area2D) -> void:
	if state_machine.state.name == "Freeze":
		return
	if area.owner is Player:
		player_collision_query(area.owner)
	elif area.owner is Enemy:
		if area.owner.z_index_dependant:
			if area.owner.z_index != z_index:
				return
		enemy_collision_query(area.owner, area)

func player_collision_query(player: Player) -> void:
	if player.state_machine.state.name == "Thrown" or player.state_machine.state.name == "Freeze" or player.is_on_floor():
		return
	var old_player_bounce_state := "Normal"
	var old_state := "Normal"
	if state_machine.state.name == "LevelFinish":
		return
	if player.carried:
		return
	if player.can_hurt == false:
		return
	if (player.velocity_lerp.y > 15 or velocity.y < 0) and global_position.y - 2 > player.global_position.y:
		if player.ground_pounding:
			pass
	else:
		return
	SoundManager.play_sfx(SoundManager.spring, self, 0.8)
	velocity = Vector2.ZERO
	player.state_machine.transition_to("Freeze", {"Gravity" = true})
	state_machine.transition_to("Freeze", {"Animating" = true})
	current_animation = "LookDown"
	sprite.play("LookDown")
	sprite.animation = "LookDown"
	animation_override = "LookDown"
	animation_player.play("Squish")
	await get_tree().create_timer(0.05, false).timeout
	player.global_position.y -= 4
	player.state_machine.transition_to(old_player_bounce_state)
	await get_tree().physics_frame
	player.bounce_off()
	animation_override = ""
	state_machine.transition_to(old_state)
	velocity.y = 100

func enemy_collision_query(enemy: Enemy, enemy_area: Area2D) -> void:
	if yoshi_item == enemy:
		return
	if enemy.is_yoshi_item:
		return
	enemy.player = self
	if invincible or (sliding and enemy.can_slide_damage):
		play_sfx("kick")
		add_jump_combo()
		enemy.die()
		return
	elif enemy.kickable:
		play_kick_animation()
		play_sfx("kick")
		enemy.die()
		return
	elif attacking and can_damage and enemy.can_cape_damage:
		if can_hurt:
			play_sfx("kick")
			enemy.die()
			return
	elif ground_pounding and not enemy.spiky_top:
			if enemy.can_hurt:
				if enemy.can_ground_pound:
					enemy.ground_pound_die()
				else:
					enemy.damage()
	elif Vector2.UP.dot(enemy_area.global_position.direction_to(global_position)) >= 0.25 and enemy.can_jump_on and not carried:
		if spin_jumping or riding_yoshi:
			if enemy.spiky_top:
				spiky_jump()
			elif enemy.can_hurt:
				if enemy.can_spin_kill:
					enemy.spin_die()
					spin_bounce_off(not riding_yoshi)
				else:
					summon_flash_particle()
					enemy.damage()
					if enemy.player_bounce_off:
						if enemy.can_add_score:
							player.play_sfx("kick")
						player.bounce_off()
		elif enemy.can_hurt and not enemy.spiky_top:
			if enemy.can_stomp_on:
				enemy.damage()
				summon_flash_particle()
				if enemy.player_bounce_off:
					add_jump_combo()
			if enemy.player_bounce_off:
				bounce_off()
		elif enemy.can_damage:
			damage()
	elif can_damage and enemy.can_damage:
		damage()

const ICE_BLOCK = preload("res://Instances/Prefabs/Interactables/ice_block.tscn")
func ice_freeze() -> void:
	state_machine.transition_to("Freeze", {"Animating" = true})
	var node = ICE_BLOCK.instantiate()
	node.global_position = global_position
	node.size = Vector2(1.5, 2)
	node.frozen_target = self
	player.set_collision_mask_value(1, false)
	player.set_collision_layer_value(1, false)
	GameManager.current_level.add_child(node)
const BIG = preload("res://Resources/PlayerPowerUpState/Big.tres")

func play_sfx(sfx_name := "", pitch := 1.0) -> void:
	SoundManager.play_sfx(get_sfx(sfx_name), self, pitch)

func play_global_sfx(sfx_name := "", pitch := 1.0) -> void:
	SoundManager.play_global_sfx(get_sfx(sfx_name), pitch)

func play_ui_sfx(sfx_name := "", pitch := 1.0) -> void:
	SoundManager.play_ui_sfx(get_sfx(sfx_name), pitch)

func get_sfx(sfx_name := "") -> String:
	if character.sound_library.sounds.has(sfx_name):
		return character.sound_library.sounds[sfx_name].resource_path
	else:
		return ""

func mega_mushroom_grow() -> void:
	player.sprite_speed_scale = 1
	player.sprite.speed_scale = 1
	process_mode = PROCESS_MODE_ALWAYS
	animation_player.play("MegaGrow")
	set_power_state(BIG)
	state_machine.transition_to("Freeze", {"Animating" = true})
	sprite.play("MegaGrow")
	animation_override = "MegaGrow"
	current_animation = "MegaGrow"
	SoundManager.play_sfx(SoundManager.mega_mushroom, self)
	MusicPlayer.mega_mushroom()
	get_tree().paused = true
	is_mega = true
	invincible = true
	await get_tree().create_timer(1).timeout
	get_tree().paused = false
	animation_override = ""
	state_machine.transition_to("Normal")
	process_mode = PROCESS_MODE_PAUSABLE
	$MegaTimer.start()

	

const YOSHI_CLOUD = preload("res://Instances/Prefabs/Interactables/yoshi_cloud.tscn")
const MUSHROOM_ITEM = preload("res://Instances/Prefabs/Items/mushroom_item.tscn")
const berry_max_values := [10, 1, 2]

func add_yoshi_berry(berry_colour := 0) -> void:
	yoshi_berries_eaten[berry_colour] += 1
	if berry_colour == 1:
		GameManager.time += 20
	if yoshi_berries_eaten[berry_colour] >= berry_max_values[berry_colour]:
		all_berries_eaten(berry_colour)
		yoshi_berries_eaten[berry_colour] = 0
		
const YOSHI_EGG = preload("res://Instances/Prefabs/Items/yoshi_egg.tscn")

func all_berries_eaten(berry_colour := 0) -> void:
	var node = YOSHI_EGG.instantiate()
	node.velocity.x = -100 * facing_direction
	node.global_position = global_position - Vector2(0, 2)
	if berry_colour == 2:
		node.custom_item = YOSHI_CLOUD
	else:
		node.custom_item = MUSHROOM_ITEM
	add_sibling(node)

func yoshi_grab_wings() -> void:
	yoshi_flying = true
	yoshi_perma_fly = true
	for i in 16:
		set_collision_mask_value(i, false)
	var cam_pos_save = camera.get_screen_center_position()
	camera.top_level = true
	camera.global_position = cam_pos_save
	SoundManager.play_sfx(SoundManager.balloon, self)
	yoshi_fly_tween()
	await get_tree().create_timer(1, false).timeout
	TransitionManager.transition_to_level("res://Instances/Levels/Bonus/coin_heaven_1.tscn", GameManager.current_level, false, null, false, "Pixel")

func handle_camera(delta: float) -> void:
	return

func yoshi_fly_tween() -> void:
	var tween = create_tween()
	tween.tween_property(self, "velocity:y", -500, 1)

func _on_online_packet_delay_timeout() -> void:
	OnlineManager.upload_level_player_packet(self)


func slam_attack() -> void:
	player.vibrate_controller()
	GameManager.shake_camera(30)
	SoundManager.play_sfx(SoundManager.bullet, player)
	ParticleManager.summon_particle(ParticleManager.GROUND_POUND_IMPACT, player.global_position)
	$SlamHitbox/CollisionShape2D.set_deferred("disabled", false)
	for i in 3:
		await get_tree().physics_frame
	$SlamHitbox/CollisionShape2D.set_deferred("disabled", true)

func _on_slam_hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Enemy and area.owner.is_on_floor():
		area.owner.melee_attack()
	if area.owner is HeldObject:
		if area.owner.destructable and area.owner.held == false:
			area.owner.die()

const BUBBLE_PARTICLE = preload("res://Instances/Particles/Player/bubble_particle.tscn")
func _on_water_bubble_timer_timeout() -> void:
	if state_machine.state.name == "Swim":
		var node = BUBBLE_PARTICLE.instantiate()
		node.global_position = global_position - Vector2(0, 16)
		add_sibling(node)
	$WaterBubbleTimer.start(randf_range(0.5, 2))
