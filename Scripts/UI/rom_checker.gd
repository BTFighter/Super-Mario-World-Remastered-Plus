extends Node

const valid_hashes := [
	"0838e531fe22c077528febe14cb3ff7c492f1f5fa8de354192bdff7137c27f5b", ## USA 1.0
	"5e3d55b019dd012e8db1498dda06b63ad1a304787625402b511e6d525946beaf", ## USA w/ header
	"d70c9c7716ad12c674fc7dd744736aa48d4d7b4237f58066be620fda26024872", ## Apparently USA?????
	
	"c6808e082ab343be554d07f2b3eb157c3c5134b364a2ffb3806a67f17e0992d0", ## JPN 1.0
	"a6549142be41d0c9efceaaddd7010341cbac8438f612f4eda410590128a03ea5", ## JPN w/ header
	
	"b5be1dba3012b6811a5660fbf2981cb23cdd1e48f845a42df00f0f55b19f0392", ## EU 1.0
	"5cc54b1e5c8d3c7701a5e20514145c3b36f15f26fe0a4fe6d2e43677e4b4eda9", ## EU 1.1
	]

var can_check := true

func _ready() -> void:
	if verify_rom():
		proceed()
	else:
		$Text/Path.text = ProjectSettings.globalize_path("user://")
		$ColorRect.hide()

func run_check() -> void:
	if can_check == false:
		return
	if verify_rom():
		success()
	else:
		fail()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		run_check()

func verify_rom() -> bool:
	var rom_path := "user://baserom.sfc"
	if !FileAccess.file_exists(rom_path):
		rom_path = "res://baserom.sfc"
	return valid_hashes.has(FileAccess.get_sha256(rom_path))

func proceed() -> void:
	TransitionManager.transition_to_menu("res://Instances/UI/Menus/disclaimer.tscn", self)

func success() -> void:
	can_check = false
	$Success.show()
	$Text.hide()
	SoundManager.play_ui_sound(SoundManager.correct)
	await get_tree().create_timer(1, false).timeout
	proceed()

func fail() -> void:
	$Success.hide()
	$Text.show()
	$Text/Error.show()
	SoundManager.play_ui_sound(SoundManager.wrong)
