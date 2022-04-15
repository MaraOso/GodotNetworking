extends Node

var PlayerIDs

func _ready():
	var PlayerIDs_file = File.new()
	PlayerIDs_file.open("user://PlayerIDs.json", File.READ)
	var PlayerIDs_json = JSON.parse(PlayerIDs_file.get_as_text())
	PlayerIDs_file.close()
	PlayerIDs = PlayerIDs_json.result

func SavePlayerIDs():
	var save_file = File.new()
	save_file.open("user://PlayerIDs.json", File.WRITE)
	save_file.store_line(to_json(PlayerIDs))
	save_file.close()
