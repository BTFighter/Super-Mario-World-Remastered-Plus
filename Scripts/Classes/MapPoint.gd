@icon("res://Assets/Sprites/Editor/Icons/MapPoint.png")
class_name MapPoint 
extends Node2D


@export_group("Info")
@export_subgroup("General")
@export_enum("Level", "Warp", "Static", "Move") var point_type := "Static"
@export_enum("Up", "Down", "Left", "Right") var move_direction := "Up"
@export var current_area: MapArea = null
@export var save_on_enter := false
@export var title := ""
@export var auto_assign_title := true

@export_subgroup("Warp Point")
@export_file("*.tscn") var map_warp := ""
@export var warp_point_name := ""
@export var return_point: MapPoint = null

@export_subgroup("Levels")
@export var level: LevelInfo = null
@export var save_level_node_info := false


@export_group("Unlocks")
@export var level_unlocked := false
@export var special_completed := false
@export var level_completed := false
@export_enum("Up", "Down", "Left", "Right", "None") var unlock_route_direction := "Up"
@export_enum("Up", "Down", "Left", "Right", "None") var special_route_direction := "Up"

var unlock_route: MapRoute
var special_route: MapRoute

signal selected
signal level_cleared
signal special_clear
signal completed_animation
signal activated

@export_group("Routes")
@export var up_route: MapRoute
const UP_COLOUR = Color.RED
@export var left_route: MapRoute
const LEFT_COLOUR = Color.GREEN
@export var down_route: MapRoute
const DOWN_COLOUR = Color.YELLOW
@export var right_route: MapRoute
const RIGHT_COLOUR = Color.ORANGE
@export var normal_path_tiles: Node = null
@export var special_path_tiles: Node = null

var visual: MapPointVisual = null

var air_ship := false

@onready var map_screen: MapLevel = owner

var map := ""
var level_path := ""


func _ready() -> void:
	if level_cleared.is_connected(clear_level) == false:
		level_cleared.connect(clear_level)
	if special_clear.is_connected(clear_special) == false:
		special_clear.connect(clear_special)
	if level != null:
		level_path = level.resource_path
	if SaveManager.current_save == {}:
		SaveManager.current_save = SaveManager.save_file_template
	if normal_path_tiles != null:
		for i in normal_path_tiles.get_children():
			i.modulate.a = 0
			i.hide()
	if special_path_tiles != null:
		for i in special_path_tiles.get_children():
			i.modulate.a = 0
			i.hide()
	if level_unlocked:
		unlock_level()
	unlock_route = get_map_route(unlock_route_direction)
	special_route = get_map_route(special_route_direction)
	if point_type != "":
		if level_completed == false:
			level_completed = check_if_beaten(SaveManager.current_save.beaten_levels)
		if special_completed == false:
			special_completed = check_if_beaten(SaveManager.current_save.special_beaten_levels)
	else:
		for i in [up_route, down_route, left_route, right_route]:
			if is_instance_valid(i):
				if i.route_unlocked:
					if is_instance_valid(i.destination_point):
						i.destination_point.unlock_level()
		level_completed = true
		special_completed = true
	if map_warp != "":
		map = map_warp
	if level != null and auto_assign_title:
		title = level.level_title
	find_visual()
	if Engine.is_editor_hint() == false:
		if unlock_route != null:
			if level_completed:
				unlock_level()
				if point_type != "Move":
					get_node(unlock_route.destination_point).unlock_level()
				unlock_route.route_unlocked = true
				unlock_path(normal_path_tiles, unlock_route, false, unlock_route_direction)
				level_completed = true
		if special_route != null:
			if special_completed:
				unlock_level()
				if point_type != "Move":
					get_node(special_route.destination_point).unlock_level()
				special_route.route_unlocked = true
				unlock_path(special_path_tiles, special_route, false, special_route_direction)
				special_completed = true
	spawn()

func spawn() -> void:
	pass

func save_game() -> void:
	pass


func get_map_route(direction := "Up"):
	match direction:
		"Up":
			return up_route
		"Down":
			return down_route
		"Left":
			return left_route
		"Right":
			return right_route

func find_visual() -> void:
	for i in get_children():
		if i is MapPointVisual:
			visual = i

func check_if_beaten(list) -> bool:
	if level == null:
		return false
	return list.has(level.resource_path)

func check_if_unlocked() -> bool:
	if level == null:
		return false
	return SaveManager.current_save.unlocked_levels.has(level.resource_path)

func _process(delta: float) -> void:
	if level != null:
		level_path = level.resource_path
	if level_unlocked:
		modulate.a = lerpf(modulate.a, 1, delta * 20)
	else:
		if visual != null:
			if visual.always_show == false:
				modulate.a = 0
		else:
			modulate.a = 0


func clear_children(node: Node) -> void:
	for i in node.get_children():
		i.queue_free()

func clear_level() -> void:
	unlock_level()
	GameManager.current_map.active_point = self
	if level != null:
		var level_node = level
		if check_if_beaten(SaveManager.current_save.beaten_levels) == false:
			SaveManager.current_save.beaten_levels.append(level.resource_path)
	SaveManager.save_current_file()
	GameManager.current_map.level_cleared.emit()
	await get_tree().process_frame
	if unlock_route != null:
		if unlock_route.route_unlocked:
			completed_animation.emit()
			return
	if not level_completed:
		if unlock_route_direction != "None" and normal_path_tiles != null:
			await unlock_path(normal_path_tiles, unlock_route, true, unlock_route_direction)
	completed_animation.emit()
	level_completed = true

func clear_special() -> void:
	unlock_level()
	GameManager.current_map.active_point = self
	if level != null:
		var level_node = level
		if check_if_beaten(SaveManager.current_save.special_beaten_levels) == false:
			SaveManager.current_save.special_beaten_levels.append(level.resource_path)
	SaveManager.save_current_file()
	GameManager.current_map.level_cleared.emit()
	await get_tree().process_frame
	if special_route != null:
		if special_route.route_unlocked:
			completed_animation.emit()
			return
	if not special_completed:
		if special_route_direction != "None" and special_path_tiles != null:
			await unlock_path(special_path_tiles, special_route, true, special_route_direction)
	completed_animation.emit()
	special_completed = true

func unlock_path(path, route, animate := true, direction := unlock_route_direction) -> void:
	route = get_map_route(direction)
	GameManager.current_map.can_move = false
	var target_point = route.destination_point
	route.route_unlocked = true
	if route == null:
		level_completed = true
	if animate:
		if path != null:
			for i in path.get_children():
				GameManager.current_map.can_move = false
				animate_path_unlock(i)
				if route.unlock_speed < 0.5:
					SoundManager.play_sfx(SoundManager.map_unlock_loop, i)
				else:
					SoundManager.play_sfx(SoundManager.map_unlock, i)
				if SettingsManager.settings_file.fast_map_unlock_speed == false: await get_tree().create_timer(route.unlock_speed, false).timeout
		if get_node(route.destination_point).level_unlocked == false:
			SoundManager.play_sfx(SoundManager.coin, self)
			ParticleManager.summon_particle(ParticleManager.GLEAM, get_node(route.destination_point).global_position)
		GameManager.current_map.can_move = true
		SaveManager.save_current_file()
	else:
		if path != null:
			for i in path.get_children():
				i.show()
				i.modulate.a = 1
	await get_tree().physics_frame
	GameManager.current_map.check_all_exits_clear()
	unlock_return_path(get_node(route.destination_point))
	get_node(route.destination_point).unlock_level()
	if animate:
		await get_tree().create_timer(0.5, false).timeout
		GameManager.current_map.travel_path(direction)
	else:
		GameManager.current_map.can_move = true

func unlock_warp_destination_path(warp_point) -> void:
	pass

func unlock_return_path(point: MapPoint) -> void:
	var dirs = ["Up", "Down", "Left", "Right"]
	var index := 0
	for i: MapRoute in [point.up_route, point.down_route, point.left_route, point.right_route]:
		if i != null:
			if get_node_or_null(i.destination_point) == self:
				i.route_unlocked = true
			elif is_instance_valid((get_node_or_null(i.destination_point))):
				if is_instance_valid(get_node(i.destination_point).return_point):
					if get_node(i.destination_point).return_point == self:
						i.route_unlocked = true
		index += 1

func animate_path_unlock(path) -> void:
	path.modulate.a = 0
	path.show()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(path, "modulate:a", 1, 0.25)

signal unlocked

func unlock_level() -> void:
	if not check_if_unlocked():
		if level != null:
			SaveManager.current_save.unlocked_levels.append(level.resource_path)
	level_unlocked = true
