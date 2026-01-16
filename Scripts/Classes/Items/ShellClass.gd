@icon("res://Assets/Sprites/Editor/Icons/Shell.png")
class_name Shell
extends HeldObject

const move_speed = 200
var shell_moving = false
var can_bounce_wall := true
@export var can_fire_damage := true
var flipped := false
var on_triangle_block := false
var slope_angle := 1
var stored_slope_velocity := 0.0

@onready var skid_particle: GPUParticles2D = $Skid
var can_launch := false

@export var entity_present := false

var upwards_slope := false
var last_floor_angle := 0.0

func spawn() -> void:
	pass


func physics_update(delta: float) -> void:
	if held:
		moving = false
		velocity.x = 0
	if entity_present:
		handle_respawn(delta)
	if shell_moving:
		sprite.play("Spin")
		skid_particle.emitting = is_on_floor()
	else:
		skid_particle.emitting = false
		sprite.play("Idle")
	if can_flip:
		sprite.flip_v = flipped
	handle_movement(delta)
	



func slope_launch() -> void:
	if not upwards_slope:
		return


func kick_upward() -> void:
	velocity.y = -400

	shell_moving = false

func handle_movement(delta: float) -> void:
	land_bounce = not shell_moving
	if shell_moving:
		if is_on_wall():
			wall_hit()
		can_pickup = false
		can_hurt_player = true
		velocity.x = move_speed * direction
	else:
		can_hurt_player = false

func wall_hit() -> void:
	if held:
		return
	if can_bounce_wall:
		if on_triangle_block:
			velocity.y = -300
		can_bounce_wall = false
		direction *= -1
		velocity.x = move_speed * direction
		SoundManager.play_sfx(SoundManager.bump, self)
		await get_tree().create_timer(0.1, false).timeout
		can_bounce_wall = true

func on_kick() -> void:
	if is_instance_valid(player):
		if player.input_direction != 0:
			direction = player.input_direction
		else:
			direction = player.facing_direction
	shell_moving = true
	bounces_left = 0
	velocity.x = move_speed * direction
	SoundManager.play_sfx(SoundManager.kick, self)

func jumped_on() -> void:
	if player.can_damage == false:
		return
	bounces_left = 0
	if shell_moving:
		can_pickup = true
		shell_moving = false
		player_bounce()
		velocity.x = 0
	else:
		player.held_object_kick()
		direction = player.direction
		shell_moving = true
		velocity.x = move_speed * direction


func player_bounce() -> void:
	player.add_jump_combo()
	player.bounce_off()
