extends Control

onready var ButtonContainer = get_node("Panel/VBoxContainer")
onready var ButtonScript = load("res://Scenes/UI/KeyButton.gd")

var keybinds
var buttons = {}

func _ready():
	keybinds = KeyBinds.keybinds.duplicate()
	for key in keybinds.keys():
		var hBox = HBoxContainer.new()
		var label = Label.new()
		var button = Button.new()
	
		hBox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		button.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		label.text = key
		var button_value = keybinds[key]
		
		if button_value != null:
			button.text = OS.get_scancode_string(button_value)
		else:
			button.text = "Unassigned"
		
		button.set_script(ButtonScript)
		button.key = key
		button.value = button_value
		button.menu = self
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		
		hBox.add_child(label)
		hBox.add_child(button)
		ButtonContainer.add_child(hBox)
		
		buttons[key] = button

func change_bind(key, value):
	keybinds[key] = value
	for k in keybinds.keys():
		if k != key and value != null and keybinds[k] == value:
			keybinds[k] = null
			buttons[k].value = null
			buttons[key].text = "Unassigned"


func _on_Back_pressed():
	queue_free()
	get_tree().paused = false


func _on_Save_pressed():
	KeyBinds.keybinds = keybinds.duplicate()
	KeyBinds.set_game_binds()
	KeyBinds.write_config()
	_on_Back_pressed()
