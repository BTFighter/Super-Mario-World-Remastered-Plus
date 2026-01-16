@icon("res://Assets/Sprites/Editor/Icons/Map.png")
class_name MapLevel
extends Node

@export var starting_point: MapPoint = null
@export var camera_lock := false
@export var camera_lock_position := Vector2.ZERO
@export var music: AudioStreamPlayer = null

@export_group("Cam Limits")
@export var cam_limit_left := -10000
@export var cam_limit_right := 10000
@export var cam_limit_top := -10000
@export var cam_limit_bottom := 10000
 
var active_point: MapPoint = null
@onready var map_path: Path2D = $MapMario
@onready var path_animation: AnimationPlayer = $MapMario/PathFollow2D/AnimationPlayer
@onready var path_follow: PathFollow2D = $MapMario/PathFollow2D

@onready var player_visual: Node2D = $PlayerVisual
@onready var mario_point: Node2D = $MapMario/PathFollow2D/MarioPoint

var airship_present := false
var move_speed := 50
var climb_speed := 25
var running := false
var paths = []
var moving := false
var current_route: MapRoute = null

var airship_queued := false

var climbing := false

var can_enter := true

var active_point_name := ""

var path_point_index := 0

signal loaded

signal level_cleared

var can_move := true

var level_path := ""

const ALL_EXIT_ACHIEVEMENT = preload("res://Resources/Achievements/Completionist/AllExit.tres")

func _enter_tree() -> void:
	TransitionManager.current_map = self
	GameManager.current_map_path = (self.get_scene_file_path())
	GameManager.current_map = self

func _ready() -> void:
	AudioServer.set_bus_effect_enabled(2, 0, false)
	GameManager.checkpoint_level = ""
	GameManager.checkpoint_level_name = ""
	GameManager.reset_values()
	MusicPlayer.map.play()
	Level.first_load = true
	check_all_exits_clear()
	update_info()
	add_points()
	if active_point != null:
		player_visual.position = player_visual.to_local(mario_point.global_position)
	if camera_lock:
		player_visual.camera.top_level = true
		player_visual.camera.global_position = camera_lock_position
	emit_signal("loaded")
	update_info()
	await get_tree().physics_frame
	print(GameManager.map_point_save)
	if get_node_or_null(GameManager.map_point_save) == null:
		active_point = starting_point
		update_info()

func add_points() -> void:
	for i in get_children():
		if i is MapPoint:
			paths.append(i)

func _process(delta: float) -> void:
	update(delta)
	handle_inputs()
	running = Input.is_action_pressed("run_0")
	player_visual.travel_offset = path_follow.progress
	if is_instance_valid(active_point):
		if active_point.point_type != "Warp" and active_point is not StarRoadWarp:
			GameManager.map_point_save = get_path_to(active_point)
			SaveManager.current_save.map_point_name = GameManager.map_point_save
	player_visual.moving = moving
	if not moving and active_point != null:
		mario_point.global_position = active_point.global_position
		path_follow.global_position = active_point.global_position
	else:
		mario_point.global_position = path_follow.global_position
	if active_point != null:
		if active_point.current_area != null:
			GameManager.current_map_area = active_point.current_area
	player_visual.global_position = mario_point.global_position
	if climbing:
		move_speed = climb_speed
	else:
		move_speed = 50
	if map_path.curve != null:
		path_animation.speed_scale = (move_speed / map_path.curve.get_baked_length())
		if running:
			path_animation.speed_scale *= 3
	if active_point != null:
		if active_point.point_type == "Move" and can_move:
			auto_move()

func check_all_exits_clear() -> void:
	var total_exits = SaveManager.current_save.beaten_levels.size() + SaveManager.current_save.special_beaten_levels.size()
	print(total_exits)
	if total_exits >= 96:
		AchievementManager.unlock_achievement(ALL_EXIT_ACHIEVEMENT)

func auto_move() -> void:
	travel_path(active_point.move_direction)

func level_completed() -> void:
	if active_point:
		active_point.level_cleared.emit()

func level_secret() -> void:
	if active_point != null:
		active_point.special_clear.emit()

func update(delta: float) -> void:
	pass

func travel_path(direction := "Up") -> void:
	if GameManager.game_paused:
		return
	match direction:
		"Up":
			current_route = active_point.up_route
		"Down":
			current_route = active_point.down_route
		"Left":
			current_route = active_point.left_route
		"Right":
			current_route = active_point.right_route
	if current_route.route_unlocked || active_point.point_type == "Move":
		if current_route.route_path != null:
			load_new_path(current_route)
			travel_new_path(current_route)
		else:
			set_to_new_point(current_route)

func update_info() -> void:
	var title = ""
	if active_point == null:
		return 
	if active_point.level != null:
		GameManager.current_level_info = active_point.level
	active_point.selected.emit()
	active_point_name = active_point.get_path()
	title = active_point.title
	if player_visual:
		player_visual.level_title.text = title

func travel_new_path(route: MapRoute) -> void:
	if can_move == false:
		return
	can_move = false
	moving = true
	if route.reverse_path:
		player_visual.travel_direction = -1
		path_animation.play_backwards("Travel")
	else:
		player_visual.travel_direction = 1
		path_animation.play("Travel")
	await path_animation.animation_finished
	can_move = true
	set_to_new_point(route)

func set_to_new_point(route: MapRoute) -> void:
	SoundManager.play_sfx(SoundManager.select, player_visual)
	active_point = active_point.get_node(route.destination_point)
	active_point.selected.emit()
	active_point_name = get_path_to(active_point)
	GameManager.map_point_save = get_path_to(active_point)
	update_info()
	if active_point.point_type == "Warp":
		change_map()
	else:
		moving = false


func change_map() -> void:
	TransitionManager.transition_to_map(active_point.map, self, false, active_point.warp_point_name, true)

func load_new_path(route: MapRoute) -> void:
	map_path.curve = route.route_path

func apply_properties(properties := "") -> void:
	pass
	

func handle_inputs() -> void:
	if can_move == false:
		return
	if active_point == null:
		return
	if Input.is_action_just_pressed("open_progress") and GameManager.current_map_area != null and GameManager.game_paused == false:
		TransitionManager.transition_to_menu("res://Instances/UI/Menus/progress_screen.tscn", self)
	if Input.is_action_just_pressed("debug_clear") and OS.is_debug_build():
		level_completed()
	if Input.is_action_just_pressed("debug_secret") and OS.is_debug_build():
		level_secret()
	
	if Input.is_action_just_pressed("jump_0") and can_enter and GameManager.game_paused == false:
		active_point.activated.emit()
	
	if active_point.point_type == "Level" and can_enter and GameManager.game_paused == false:
		if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", 0)):
			enter_level()
	
	if active_point.down_route != null:
		if Input.is_action_just_pressed("move_down_0"):
			travel_path("Down")
			return
	
	if active_point.left_route != null:
		if Input.is_action_just_pressed("move_left_0"):
			travel_path("Left")
			return
	
	if active_point.right_route != null:
		if Input.is_action_just_pressed("move_right_0"):
			travel_path("Right")
			return
	
	if active_point.up_route != null:
		if Input.is_action_just_pressed("move_up_0"):
			travel_path("Up")
			return

func enter_level() -> void:
	can_enter = false
	can_move = false
	MusicPlayer.map.stop()
	if is_instance_valid(music):
		music.stop()
	player_visual.level_enter()
	await player_visual.enter_level
	GameManager.starting_level = active_point.level.level_title
	GameManager.current_level_info = active_point.level
	GameManager.starting_level_path = active_point.level.level_scene_path
	SoundManager.play_ui_sound(SoundManager.enter_save)
	await get_tree().create_timer(1, false).timeout
	var scene_path = active_point.level.level_scene_path
	if active_point.level.start_cutscene_path != "":
		TransitionManager.cutscene_level = scene_path
		scene_path = active_point.level.start_cutscene_path
	TransitionManager.transition_to_level(scene_path, self, false, null, true)
