extends Node


var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1911

func _ready():
	ConnectToServer()

func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

func _OnConnectionFailed():
	print("Failed to Connect to Authetication Server")
	
func _OnConnectionSucceeded():
	print("Successfully Connected to Authentication Server")

func AuthenticatePlayer(username, password, player_id):
	print("Sending Out Authentication Request")
	rpc_id(1, "AuthenticatePlayer", username, password, player_id)

remote func AuthenticationResults(result, player_id, token):
	print("Results Recieved and Replying to Player Login Request")
	Gateway.ReturnLoginRequest(result, player_id, token)

func CreateAccount(username, password, player_id):
	print("Sending out create account request")
	rpc_id(1, "CreateAccount", username, password, player_id)

remote func CreateAccountResults(result, player_id, message):
	print("Results recieved and replying to player create account request")
	Gateway.ReturnCreateAccountRequest(result, player_id, message)
