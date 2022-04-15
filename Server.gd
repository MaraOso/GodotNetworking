extends Node

var network = NetworkedMultiplayerENet.new()
var ip = '127.0.0.1'
var port = 1909

var latency = 0
var client_clock = 0
var decimal_collector : float = 0
var latency_array = []
var delta_latency = 0
var currentUser = ""

var token

func _ready():
	pass
	#ConnectToServer()

func _physics_process(delta):
	client_clock += int(delta*1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00

func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)

	network.connect('connection_failed', self, '_OnConnectionFailed')
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")


func _OnConnectionFailed():
	print("Failed to Connect")


func _OnConnectionSucceeded():
	print("Successfully Connected")
	rpc_id(1, "FetchServerTime", OS.get_system_time_msecs())
	var timer = Timer.new()
	timer.wait_time = .5
	timer.autostart = true
	timer.connect("timeout", self, "DetermineLatency")
	self.add_child(timer)
	rpc_id(1, "SetPlayerName", currentUser)

remote func ReturnServerTime(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency

func DetermineLatency():
	rpc_id(1, "DetermineLatency", OS.get_system_time_msecs())

remote func ReturnLatency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size() - 1, -1, -1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		#print("New Latency ", latency)
		#print("Delta Latency ", delta_latency)
		latency_array.clear()

remote func FetchToken():
	rpc_id(1, "ReturnToken", token)

remote func ReturnTokenVerificationResults(result):
	if result == true:
		get_node("../SceneHandler/LoginScreen").queue_free()
		get_node("../SceneHandler/Map/Entities/Player").set_physics_process(true)
		print("Successful Token Verification")
	else:
		print("Login Failed, please try again")
		get_node("../SceneHandler/LoginScreen").login_button.disabled = false
		get_node("../SceneHandler/LoginScreen").register_button.disabled = false

#0 for everyone, 1 for server, 2 for other player (Neveruse)

func IncreaseSTR():
	rpc_id(1, "IncreaseSTR")

func FetchPlayerStats():
	rpc_id(1, "FetchPlayerStats")

remote func ReturnPlayerStats(stats):
	#print(stats)
	get_node("/root/SceneHandler/Map/Entities/Player/CanvasLayer/PlayerStats").playerStats = stats

remote func SpawnNewPlayer(player_id, spawn_position):
	get_node("../SceneHandler/Map").SpawnNewPlayer(player_id, spawn_position)

remote func DespawnPlayer(player_id):
	get_node("../SceneHandler/Map").DespawnPlayer(player_id)

func SendAttack(position, a_position, a_direction):
	rpc_id(1, "Attack", position, client_clock, a_position, a_direction)
	
remote func ReceiveAttack(position, spawn_time, player_id):
	if player_id == get_tree().get_network_unique_id():
		pass
	else:
		get_node("/root/SceneHandler/Map/Entities/OtherPlayers/" + str(player_id)).attack_dict[spawn_time] = {"Position":position}

func SendPlayerState(player_state):
	#print(player_state)
	rpc_unreliable_id(1, "ReceivePlayerState", player_state)

remote func ReceiveWorldState(world_state):
	if get_tree().get_rpc_sender_id() == 1: #place this on all remote calls
		#print(world_state)
		get_node("../SceneHandler/Map").UpdateWorldState(world_state)
		#print("WorldState: ", world_state["T"], " && client_clock: ", client_clock)
