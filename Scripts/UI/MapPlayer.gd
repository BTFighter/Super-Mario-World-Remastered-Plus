class_name MapPlayer
extends Node2D

@onready var camera: Camera2D = $Camera2D

@export_enum("Up", "Down", "Left", "Right") var direction := "Up"
@onready var level_title: Label = $HUD/LevelTitle
@onready var running_sfx: AudioStreamPlayer2D = $RunningSFX
@onready var circle_animation: AnimationPlayer = $HUD/Circle/AnimationPlayer

var moving := false
@onready var hud: CanvasLayer = $HUD

signal pause

var waiting := false

var camera_scrolling := false

var camera_speed := 150

var running := false
var menu_open := false

var can_lerp := false

var travel_offset := 0.0

var player_spacing := 16

var travel_direction := 1

var direction_vectors: Array[Vector2] = [Vector2.UP, Vector2.UP, Vector2.UP, Vector2.UP]
var player_direction := ["", "", "", ""]
@onready var sprite_positions: Node2D = $SpritePositions

@onready var player_sprites = [$Player1Sprite, $Player2Sprite, $Player3Sprite, $Player4Sprite]
@onready var follower_sprites = [$Player2Sprite, $Player3Sprite, $Player4Sprite]
@onready var follower_idle_positions = [$SpritePositions/P2, $SpritePositions/P3, $SpritePositions/P4]

@onready var player_hud_sprites = [$HUD/Player1Sprite, $HUD/Player2Sprite, $HUD/Player3Sprite, $HUD/Player4Sprite]
@onready var sprite: AnimatedSprite2D = $Player1Sprite


var player_position := [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
var player_move_types := ["", "", "", ""]

var players_climbing := [false, false, false, false]
var players_swimming := [false, false, false, false]
var climbing := false
var spinning := false
var current_player_1_animation := ""

const YOSHI_COLOURS := [[Color("00F800"), Color("00B800"), Color("D8C8A8"), Color("D08048")], [Color("F80000"), Color("B80000"), Color("F8D0C0"), Color("E87958")], [Color("8888F8"), Color("6868D8"), Color("E800B0"), Color("F8D0C0")], [Color("F8F800"), Color("F8C000"), Color("F88800"), Color("B82800")]]

signal enter_level
@onready var camera_arrows: Node2D = $HUD/CameraArrows

func _ready() -> void:
	hud.show()
	get_parent().player_visual = self
	setup_player_sprites()
	setup_hud_player_sprites()

func _process(delta: float) -> void:
	running = get_parent().running and moving
	if running:
		if running_sfx.is_playing() == false:
			running_sfx.play()
		for i in player_sprites:
			i.speed_scale = 5
	else:
		for i in player_sprites:
			if moving:
				i.speed_scale = 1.5
			else:
				i.speed_scale = 1
		running_sfx.stop()
	$HUD/HBoxContainer/LifeCount.text = "*" + str(GameManager.lives)
	get_parent().climbing = players_climbing[0]
	handle_camera_scrolling(delta)
	handle_directions()
	handle_player_tiles()
	handle_player_sprites()
	$HUD/Circle.position = player_sprites[0].get_global_transform_with_canvas().origin - Vector2(480, 270)
	if moving:
		handle_player_trail(delta)
	else:
		handle_follower_idle(delta)

func setup_player_sprites() -> void:
	var player_index := 0
	for i in player_sprites:
		if is_instance_valid(CoopManager.player_characters[player_index]):
			i.sprite_frames = CoopManager.player_characters[player_index].map_sprites
		player_index += 1
	player_index = 0
	for i in follower_sprites:
		i.global_position = follower_idle_positions[player_index].global_position
		player_index += 1
	for i in CoopManager.players_connected - 1:
		follower_sprites[i].show()

func handle_player_tiles() -> void:
	for i in 4:
		players_climbing[i] = player_sprites[i].get_node("TileChecks/Climb").is_colliding()
		players_swimming[i] = player_sprites[i].get_node("TileChecks/Water").is_colliding()

func setup_hud_player_sprites() -> void:
	var player_frames = []
	var player_index := 0
	var play_con_diff = 4 - (CoopManager.players_connected)
	var player_charcters = []
	player_index = 0
	for i in player_hud_sprites:
		player_index += 1
		i.hide()
	player_index = 0
	var sprite_index := 0
	for i in player_hud_sprites:
		if player_index >= play_con_diff:
			i.show()
			i.character = CoopManager.player_characters[sprite_index]
			i.riding_yoshi = CoopManager.player_yoshis[sprite_index]
			i.power_state = load(CoopManager.player_power_states[sprite_index])
			i.yoshi_colour = CoopManager.yoshi_colours[sprite_index]
			i.update_display()
			sprite_index += 1
		player_index += 1


func handle_camera_scrolling(delta: float) -> void:
	const left_mod := 80
	const right_mod := 80
	const top_mod := 45
	const bot_mod := 59
	
	var map = GameManager.current_map
	var input_vector = Input.get_vector("move_left_0", "move_right_0", "move_up_0", "move_down_0")
	if GameManager.current_map.camera_lock == false:
		camera.limit_left = map.cam_limit_left - left_mod
		camera.limit_right = map.cam_limit_right + right_mod
		camera.limit_top = map.cam_limit_top - top_mod
		camera.limit_bottom = map.cam_limit_bottom + bot_mod
		if GameManager.current_map.can_move:
			if Input.is_action_just_pressed("spin_jump_0"):
				camera_scrolling = true
		if camera_scrolling:
			GameManager.current_map.can_move = false
			if Input.is_action_just_released("spin_jump_0"):
				camera_scrolling = false
				GameManager.current_map.can_move = true
			camera.position += camera_speed * input_vector.normalized() * delta
		elif GameManager.current_map.camera_lock == false:
			camera.position = lerp(camera.position, Vector2.ZERO, 1)
		camera_arrows.visible = camera_scrolling
	else:
		camera.global_position = GameManager.current_map.camera_lock_position
	if GameManager.current_map.camera_lock == false:
		camera.global_position.x = clamp(camera.global_position.x, map.cam_limit_left + (left_mod * 2), map.cam_limit_right - (right_mod * 2))
		camera.global_position.y = clamp(camera.global_position.y, map.cam_limit_top + (top_mod * 2), map.cam_limit_bottom - (bot_mod * 2))

func get_4way_direction(direction_vector := Vector2.ZERO) -> String:
	var abs_x = abs(direction_vector.x)
	var abs_y = abs(direction_vector.y)
	if direction_vector == Vector2.ZERO:
		return "Down"
	if abs_x >= abs_y:
		if direction_vector.x >= 0:
			return "Right"
		else:
			return "Left"
	else:
		if direction_vector.y <= 0:
			return "Up"
		else:
			return "Down"

func handle_player_sprites() -> void:
	var player_index := 0
	for i in player_sprites:
		var animation = handle_animations(player_index, player_direction[player_index], player_move_types[player_index])
		if is_instance_valid(i.sprite_frames):
			if i.sprite_frames.has_animation(animation):
				i.play(animation)
		i.material.set_shader_parameter("colour_1", YOSHI_COLOURS[CoopManager.yoshi_colours[player_index]][0])
		i.material.set_shader_parameter("colour_2", YOSHI_COLOURS[CoopManager.yoshi_colours[player_index]][1])
		i.material.set_shader_parameter("arm_colour", YOSHI_COLOURS[CoopManager.yoshi_colours[player_index]][2])
		i.material.set_shader_parameter("arm_2_colour", YOSHI_COLOURS[CoopManager.yoshi_colours[player_index]][3])
		player_index += 1

func handle_directions() -> void:
	var player_index := 0
	for i in player_sprites:
		var compare_vector: Vector2 = player_position[player_index].direction_to(i.global_position).snapped(Vector2(0.5, 0.5))
		direction_vectors[player_index] = compare_vector
		player_position[player_index] = i.global_position
		player_direction[player_index] = get_4way_direction(compare_vector)
		player_index += 1

func handle_player_trail(delta) -> void:
	can_lerp = true
	var player_index := 0
	for i in follower_sprites:
		var target_position = get_parent().path_follow.get_parent().curve.sample_baked(travel_offset - ((player_spacing * (player_index + 0.5)) * travel_direction))
		i.global_position = lerp(i.global_position, target_position, (delta * 15) if can_lerp else 1)
		player_index += 1

func handle_follower_idle(delta) -> void:
	var player_index := 0
	for i in follower_sprites:
		var target_position = follower_idle_positions[player_index].global_position
		i.global_position = lerp(i.global_position, target_position, (delta * 15) if can_lerp else 1)
		player_index += 1

func handle_animations(player_index := 0, direction := "", ground_type := "") -> String:
	var animation := ""
	var move_type := ""
	var yoshi := ""
	var climbing = players_climbing[player_index]
	var swimming = players_swimming[player_index]
	var riding_yoshi = CoopManager.player_yoshis[player_index]
	if waiting:
		direction = ""
	elif not moving:
		direction = "Down"
	if riding_yoshi:
		yoshi = "Yoshi"
		if climbing:
			return "YoshiWalkUp"
	if spinning:
		return yoshi + "Spin"
	elif climbing and moving:
		return "Climb"
	if not waiting:
		if swimming:
			move_type += "Swim"
		else:
			move_type = "Walk"
	else:
		if swimming:
			move_type += "Swim"
		move_type += "EnterLevel"
	animation = yoshi + move_type + direction
	return animation

func close_menu() -> void:
	pause.emit()

func level_enter() -> void:
	SoundManager.play_ui_sound(SoundManager.correct)
	auto_pause()
	waiting = true
	await pause
	circle_animation.play("Enter")
	enter_level.emit()

func auto_pause() -> void:
	await get_tree().create_timer(.4).timeout
	if not menu_open:
		pause.emit()


func _on_online_upload_timeout() -> void:
	OnlineManager.upload_field_player_packet(self)
