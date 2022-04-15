extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1910
var cert = load("res://Resources/Certificate/X509_Certificate.crt")

var username
var password
var new_account = false

func _ready():
	pass

func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func ConnectToServer(_username, _password, _new_account):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false)
	network.set_dtls_certificate(cert)
	username = _username
	password = _password
	new_account = _new_account
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

func _OnConnectionFailed():
	print("Failed to Connect to Login Server")
	print("Pop-up Server Offline")
	#get_node("../SceneHandler/Map/GUI/LoginScreen").login_button.disabled = true
	get_node("../SceneHandler/LoginScreen").login_button.disabled = false
	get_node("../SceneHandler/LoginScreen").register_button.disabled = false
	get_node("../SceneHandler/LoginScreen").confirm_button.disabled = false
	get_node("../SceneHandler/LoginScreen").back_button.disabled = false
	
func _OnConnectionSucceeded():
	print("Successfully Connected to Login Server")
	if new_account == true:
		RequestCreateAccount()
	else:
		RequestLogin()

func RequestLogin():
	print("Connecting to Gateway to Request Login")
	rpc_id(1, "LoginRequest", username, password.sha256_text())
	username = ""
	password = ""

remote func ReturnLoginRequest(results, token):
	print("Results Recieved")
	if results == true:
		Server.token = token
		Server.ConnectToServer()
		#get_node("../SceneHandler/LoginScreen").queue_free()
	else:
		print("Please Provide Correct Username and Password")
		get_node("../SceneHandler/LoginScreen").register_button.disabled = false
		get_node("../SceneHandler/LoginScreen").login_button.disabled = false
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")

func RequestCreateAccount():
	print("Requesting new account")
	rpc_id(1, "CreateAccountRequest", username, password.sha256_text())
	username = ""
	password = ""

remote func ReturnCreateAccountRequest(result, message):
	print("result recieved")
	if result == true:
		print("Account Created, please proceed with logging in")
		get_node("../SceneHandler/LoginScreen")._on_Back_pressed()
	else:
		if message == 1:
			print("Couldn't create account, please try again")
		elif message == 2:
			print("Username already exist, please use a different username")
		get_node("../SceneHandler/LoginScreen").confirm_button.disabled = false
		get_node("../SceneHandler/LoginScreen").back_button.disabled = false
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
