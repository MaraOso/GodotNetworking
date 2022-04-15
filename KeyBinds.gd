extends Node

var configFile
var filePath = "res://Data/keybinds.ini"

var keybinds = {}

onready var KeyBindMenu = load("res://Scenes/UI/Keybinding.tscn")

func _ready():
	configFile = ConfigFile.new()
	if configFile.load(filePath) == OK:
		for key in configFile.get_section_keys("keybinds"):
			var key_value = configFile.get_value("keybinds", key)
			
			if str(key_value) != "":
				keybinds[key] = key_value
			else:
				keybinds[key] = null
	else:
		print("Failure")
		get_tree().quit()
	
	set_game_binds()

func set_game_binds():
	for key in keybinds.keys():
		var value = keybinds[key]
		
		var actionList = InputMap.get_action_list(key)
		if !actionList.empty():
			InputMap.action_erase_event(key, actionList[0])
		
		if value != null:
			var new_key = InputEventKey.new()
			new_key.set_scancode(value)
			InputMap.action_add_event(key, new_key)

func _input(_event):
	if Input.is_key_pressed(KEY_ESCAPE):
		add_child(KeyBindMenu.instance())
		get_tree().paused = true

func write_config():
	for key in keybinds.keys():
		var key_value = keybinds[key]
		if key_value != null:
			configFile.set_value("keybinds", key, key_value)
		else:
			configFile.set_value("keybinds", key, "")
		configFile.set_value("keybinds", key, key_value)
	configFile.save(filePath)
