extends Control

onready var chatLog = get_node("VBoxContainer/RichTextLabel")
onready var inputLabel = get_node("VBoxContainer/HBoxContainer/Label")
onready var inputField = get_node("VBoxContainer/HBoxContainer/LineEdit")

var groups = [
	{"name":'Team', 'colour':'#34c5f1'},
	{"name":'Match', 'colour':'#f1c234'},
	{"name":'Global', 'colour':'#ffffff'},
]

var group_index = 0
var user_name = "MVentusr"
#var user_name = Server.currentUser

func _ready():
	inputField.connect("text_entered", self, "text_entered")
	add_message("KaiseStory", "Press ALT to Minimize Screen", 2)
	change_group(0)

func _input(event):
	#if event.pressed and event.scancode == KEY_ENTER
	if event.is_action_pressed("Send"):
		inputField.grab_focus()
	if event is InputEventKey:
		if event.is_pressed() and event.scancode == KEY_ESCAPE:
			inputField.release_focus()
		if event.is_pressed() and event.scancode == KEY_TAB:
			change_group(1)
		if event.is_pressed() and event.scancode == KEY_ALT:
			chatLog.hide()
		

func change_group(value):
	group_index += value
	if group_index > (groups.size() - 1):
		group_index = 0
	if group_index < 0:
		group_index = groups.size() - 1
	inputLabel.text = '[' + groups[group_index]['name'] + ']'
	inputLabel.set('custom_colors/font_color', Color(groups[group_index]['colour']))

func add_message(username, text, group = 0):
	chatLog.bbcode_text += "\n" 
	chatLog.bbcode_text += '[color=' + groups[group]['colour'] + ']'
	chatLog.bbcode_text += '[' + username + ']: '
	chatLog.bbcode_text += text
	chatLog.bbcode_text += '[/color]'

func text_entered(text):
	if text == '/h':
		add_message('help', "There's no helping you.", 2)
		inputField.text = ""
		return
	if text == "":
		return
	add_message(user_name, text, group_index)
	inputField.text = ''
