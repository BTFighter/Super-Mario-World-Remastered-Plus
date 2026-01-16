extends Node

@onready var fade_transition: ColorRect = $CanvasLayer/FadeTransition
@onready var circle_transition: ColorRect = $CanvasLayer/CircleTransition
@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var loading_icon: Node2D = $CanvasLayer/LoadingIcon
const TITLE_SCREEN = ("res://Instances/UI/Menus/title_screen.tscn")
signal level_transitioned
var previous_area: Level = null
var current_level: Level = null
var current_map: MapLevel = null
var level_to_transition: Level = null

var starting_player_position := Vector2.ZERO

var cutscene_level := ""

@onready var level_start: Label = $CanvasLayer/LevelStart

@onready var players = [$CanvasLayer/LoadingIcon, $CanvasLayer/LoadingIcon/LoadingIcon2, $CanvasLayer/LoadingIcon/LoadingIcon3, $CanvasLayer/LoadingIcon/LoadingIcon4]

var pipe_id := 0
var pipe_exit_direction := ""

var changing_scene := false
var scene_loading := ""

var loading_scene := false

signal scene_loaded

signal pipe_enter

const TIPS := [
	"Hold down the jump button to bounce higher off enemies.",
	"Collect 100 coins to earn an extra life!",
	"Spin jumping will allow you to break through certain blocks and defeat tougher enemies!",
	"Flying with the cape requires a running start.",
	"Check every nook and cranny of a level! Hidden blocks and secrets are everywhere!",
	"Hit the top of the goal post to maximise star points!",
	"Certain pipes can transport you to hidden areas or bonus levels.",
	"Press down while on a sloped floor, to slide and knock down enemies!",
	"Revisit Ghost Houses, they often have multiple exits.",
	"Keep hold of reserved power-ups for when you really need them.",
	"Each coloured Yoshi has a unique ability when eating different coloured Koopa Shells!",
	"Use the cape to slow your descent and make precise landings.",
	"You can cross one-block gaps while running.",
	"Always be on the lookout for secret keys and keyholes to unlock new paths.",
	"Use the P-Switches to reveal hidden coins, paths and doors.",
	"Practice makes perfect! Try practising moves in easier levels."
	]


func _ready() -> void:
	_on_timer_timeout()

func _process(delta: float) -> void:
	var load_progress := 0.0
	var progress = [0.0]
	if loading_scene:
		load_progress = ResourceLoader.load_threaded_get_status(scene_loading, progress)
		if load_progress == ResourceLoader.THREAD_LOAD_LOADED:
			scene_loaded.emit()
		load_progress = clamp(load_progress, 0, 1)
		loading_icon.position.x = lerpf(loading_icon.position.x, lerpf(0, 480 * 2, progress[0]), delta * 5)

func show_level_start() -> void:
	if SettingsManager.settings_file.show_level_start_text == true:
		await get_tree().create_timer(0.5).timeout
		level_start.show()
		await get_tree().create_timer(1).timeout
		level_start.hide()
		await get_tree().create_timer(0.5).timeout
	return


func pipe_transition_to_level(level: String, old, id, save := true) -> void:
	changing_scene = true
	pipe_id = id
	await transition_in("Pixel")
	CoopManager.pipe_exiting = true
	if is_instance_valid(GameManager.current_level):
		GameManager.current_level.save_objects(GameManager.run_states)
	var level_node = await change_scene(old, level)
	level_node.pipe_enter = true
	changing_scene = false
	level_to_transition = null
	emit_signal("pipe_enter")
	await get_tree().physics_frame
	level_transitioned.emit()
	changing_scene = false
	transition_out("Pixel")

func check_level_theme(_level) -> void:
	pass

var transition_type := "Fade"

func show_transition(animation := "Fade") -> void:
	transition_type = animation
	animation_player.play(transition_type)
	loading_icon.position.x = 0
	for i in players:
		i.update_display()
	await level_transitioned
	print(transition_type)
	animation_player.play_backwards(transition_type)
	return

func change_scene(old_scene, new_scene) -> Node:
	if is_instance_valid(old_scene):
		old_scene.queue_free()
	var scene_node
	if new_scene is String:
		scene_node = await load_scene(new_scene)
	else:
		scene_node = new_scene
	get_tree().root.add_child(scene_node)
	level_transitioned.emit()
	get_tree().paused = false
	return scene_node

func transition_to_level(level: String, old_level = GameManager.current_level, save = true, position = null, show_message := false, transition_type := "Fade") -> void:
	if changing_scene:
		return
	print(position)
	changing_scene = true
	level_start.hide()
	await transition_in(transition_type)
	if old_level:
		if old_level is Level and save:
			old_level.save_objects(GameManager.run_states)
		old_level.queue_free()
	var level_node = await load_scene(level)
	if show_message:
		await show_level_start()
	await change_scene(old_level, level_node)
	get_tree().paused = false
	level_to_transition = null
	if position != null:
		if is_instance_valid(CoopManager.get_first_any_player()):
			CoopManager.get_first_any_player().global_position = position
	changing_scene = false
	await get_tree().physics_frame
	transition_out("Pixel")

func transition_to_map(map_scene = "", old = GameManager.current_map, completed = false, warp_point := "", map_to_map := false, special_clear := false) -> void:
	if changing_scene:
		return
	changing_scene = true
	await transition_in("Circle")
	GameManager.course_clear.cancel_finish()
	if map_to_map:
		GameManager.map_point_save = warp_point
	var map = await change_scene(old, map_scene)
	if map_to_map:
		map.active_point = map.get_node(warp_point)
	elif GameManager.map_point_save != "":
		map.active_point = map.get_node(GameManager.map_point_save)
	else:
		map.active_point = map.starting_point
	if special_clear:
		map.level_secret()
	elif completed:
		map.level_completed()
	if warp_point != "":
		map.active_point_name = (warp_point)
	map.update_info()
	await get_tree().physics_frame
	level_transitioned.emit()
	changing_scene = false
	transition_out("Circle")

func load_scene(scene_path := "") -> Node:
	loading_scene = true
	scene_loading = scene_path
	ResourceLoader.load_threaded_request(scene_path)
	await scene_loaded
	loading_scene = false
	scene_loading = ""
	var result = ResourceLoader.load_threaded_get(scene_path) as PackedScene
	get_tree().paused = false
	assert(is_instance_valid(result), "Load Failed! Invalid Scene Path! Scene Path: " + ( "NULL" if scene_path == "" else scene_path))
	return result.instantiate()

func reset_gamemanager_values() -> void:
	GameManager.reset_values()

func death_load() -> void:
	Level.first_load = true
	if GameManager.checkpoint_level == "":
		GameManager.run_states = {}
		transition_to_level((GameManager.starting_level_path), GameManager.current_level, false)
		await TransitionManager.level_transitioned
		GameManager.level_time = 0
	elif GameManager.starting_level_path == "":
		GameManager.run_states = {}
		reload_level()
	else:
		GameManager.run_states = GameManager.check_point_run_states
		transition_to_level((GameManager.checkpoint_level), GameManager.current_level, false)

func transition_to_menu(menu, old = GameManager.current_map) -> void:
	if changing_scene:
		return
	changing_scene = true
	show_transition()
	await get_tree().create_timer(0.25).timeout
	GameManager.run_states = {}
	MusicPlayer.stop_level_music()
	MusicPlayer.stop_music_override(MusicPlayer.music_override.stream, true)
	reset_gamemanager_values()
	await change_scene(old, menu)
	changing_scene = false

func reload_level() -> void:
	if changing_scene:
		return
	changing_scene = true
	animation_player.play("Fade")
	GameManager.time = 300
	reset_gamemanager_values()
	GameManager.current_level.pipe_enter = false
	GameManager.player.first_load = true
	GameManager.stopwatch_enabled = false
	MusicPlayer.stop_level_music()
	MusicPlayer.stop_music_override(MusicPlayer.music_override.stream, true)
	await animation_player.animation_finished
	var reset_level = load(GameManager.current_level.scene_file_path).instantiate()
	GameManager.current_level.queue_free()
	GameManager.ghost_index = 0
	GameManager.racing_ghost = false
	
	await get_tree().create_timer(0.25).timeout
	get_tree().root.add_child(reset_level)
	get_tree().paused = false
	await get_tree().physics_frame
	changing_scene = false
	level_transitioned.emit()
	animation_player.play_backwards("Fade")

func get_transition_sprites() -> void:
	handle_player_icons()

func handle_player_icons() -> void:
	var player_index := 0
	for i in players:
		i.hide()
	for i in CoopManager.players_connected:
		players[i].show()
	for i in players:
		i.character = CoopManager.player_characters[player_index]
		i.riding_yoshi = CoopManager.player_yoshis[player_index]
		i.yoshi_colour = CoopManager.yoshi_colours[player_index]
		i.power_state = load(CoopManager.player_power_states[player_index])
		player_index += 1
@onready var pixel_transition: ColorRect = $CanvasLayer/PixelTransition

func transition_in(transition_type := "Fade") -> void:
	animation_player.play(transition_type)
	await animation_player.animation_finished
	loading_icon.visible = true


func transition_out(transition_type := "Fade") -> void:
	loading_icon.visible = false
	await get_tree().create_timer(0.1, false).timeout
	animation_player.play_backwards(transition_type)


func _on_timer_timeout() -> void:
	$CanvasLayer/LoadingIcon/Tip.text = "Tip: " + TIPS.pick_random()
