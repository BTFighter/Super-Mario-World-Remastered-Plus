extends Level

@onready var lines = $Message.get_children()
@export var egg_index := 0

@onready var player_1: PlayerSpriteDisplay = $Player1
@onready var player_2: PlayerSpriteDisplay = $Player2
@onready var player_3: PlayerSpriteDisplay = $Player3
@onready var player_4: PlayerSpriteDisplay = $Player4


func _ready() -> void:
	player_2.visible = CoopManager.players_connected > 1
	player_3.visible = CoopManager.players_connected > 2
	player_4.visible = CoopManager.players_connected > 3
	
	var index := 0
	
	for i in [player_1, player_2, player_3, player_4]:
		i.character = CoopManager.player_characters[index]
		i.power_state = load(CoopManager.player_power_states[index])
		index += 1

func show_lines() -> void:
	for i in lines:
		if i is ColorRect:
			i.hide()
			await get_tree().create_timer(0.75).timeout

func finish() -> void:
	SaveManager.current_save.eggs_rescued[egg_index] = true
	print(SaveManager.current_save)
	TransitionManager.transition_to_map(GameManager.current_map_path, self, true)
	
func _process(delta: float) -> void:
	SaveManager.current_save.eggs_rescued[egg_index] = true
	print(SaveManager.current_save)
	if Input.is_action_just_pressed("ui_accept"):
		TransitionManager.transition_to_map(GameManager.current_map_path, self, true)
