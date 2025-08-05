extends Node2D

signal run_starting()
signal run_started()
signal run_finishing()
signal run_finished()
signal run_error()
signal replay_finished()

enum RunStatus {
	NOT_STARTED,
	STARTING,
	STARTED,
	FINISHING,
	FINISHED,
	ERROR
}

# Configuration
var game_id: String = ""
var server_url: String = "http://kadokadeo.localhost"
var run_status: RunStatus = RunStatus.NOT_STARTED:
	set(value):
		run_status = value
		if run_status == RunStatus.STARTING:
			run_starting.emit()
		elif run_status == RunStatus.STARTED:
			run_started.emit()
		elif run_status == RunStatus.FINISHING:
			run_finishing.emit()
		elif run_status == RunStatus.FINISHED:
			run_finished.emit()
		elif run_status == RunStatus.ERROR:
			run_error.emit()

# Composants
var api_client: ApiClient = ApiClient.new()
var crypto: KadoCrypto = KadoCrypto.new()
#var replay_recorder: ReplayRecorder
#var replay_player: ReplayPlayer
var loading_screen: Control
var is_initialized_flag: bool = false
var run_details: StartRunData

func _init() -> void:
	if OS.is_debug_build():
		api_client.auth_token = "5|hVU0kWVbEGf5wShqpZKnQ3DQ66XECQf7XEOwt9cidaf22d85"  # Token de test
		crypto.set_server_public_key("-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAo9up6S3lC/loutVnBN/u
nbh5MFH6hjsjUAgvHA0ohI/CJr/wlfo0p4BkDRPC9qj8Eirff+vB3xMB7lIBq+Nt
ij2zvvvKXeUz+2he9mYCE1iU6L0UxflnPhh9wR5YnrVkH9tap9ZV8L2TT2SKma3m
nrTnTddUFWLON7I1yy9EMLsc3XVwc5nKmnM3qGiHf0PA5wE566CV2jHcyQ20cwip
jlcFzxFxDRIg47Ffi+XDkr19DKZtGuvDI8WC+8ijsoJMEm5qLK2EK18uhqkYcaCD
DUjZb/NinYM4bN6tydoyx1vvx03Umq4NOc4/1OwqMA/VSl5xZx9rznN15zxKZOkh
XQIDAQAB
-----END PUBLIC KEY-----")
	else:
		var kado_obj = JavaScriptBridge.get_interface("Kado")
		print(kado_obj.token)
		api_client.auth_token = kado_obj.token
		crypto.set_server_public_key(kado_obj.public_key)

func _ready():
	name = "KadokadeoManager"
	set_process(false)
	add_child(api_client)
	
	# Initialiser les composants
	#replay_recorder = ReplayRecorder.new()
	#replay_player = ReplayPlayer.new()
	
	#add_child(replay_recorder)
	#add_child(replay_player)
	
	# Connecter les signaux
	#replay_player.replay_finished.connect(_on_replay_finished)

func initialize(p_game_id: String, p_server_url: String = "") -> void:
	if p_game_id.is_empty():
		push_error("KadokadeoDevKit: game_id cannot be empty")
		return
		
	game_id = p_game_id
	if not p_server_url.is_empty():
		server_url = p_server_url
		
	api_client.configure(server_url)
	is_initialized_flag = true
	print("KadokadeoDevKit initialized for game: ", game_id)

func start_game_session() -> void:
	if not is_initialized_flag:
		push_error("KadokadeoDevKit: Must initialize before starting session")
		return
		
	if run_status == RunStatus.STARTING:
		print("KadokadeoDevKit: Session already starting...")
		return
		
	run_status = RunStatus.STARTING
	
	# Appel API pour démarrer la session
	var response = await api_client.post_request("/api/runs/games/" + game_id, {})
	if response.success:
		print(response.data)
		run_details = StartRunData.new(response.data)
		run_status = RunStatus.STARTED
	else:
		run_status = RunStatus.ERROR

func end_game_session() -> void:
	if run_status == RunStatus.STARTED:
		# Arrêter l'enregistrement si en cours
		#if replay_recorder.is_recording():
		#	replay_recorder.stop_recording()
			
		run_status = RunStatus.FINISHING
		var endpoint = "/api/runs/" + run_details.run_id + "/finish"
		var end_run_request = {
			'run_id': run_details.run_id,
			'score': GameState.score,
			'timestamp': run_details.server_time
		}
		var payload = crypto.prepare_payload(JSON.stringify(end_run_request))
		api_client.post_request(endpoint, {
			'payload': payload.payload,
			'key': payload.key,
			'sign': payload.sign
		})
		print("KadokadeoDevKit: Session ended")

# === REPLAY SYSTEM ===

# func start_recording() -> void:
# 	if not is_initialized_flag:
# 		push_error("KadokadeoDevKit: Must initialize before recording")
# 		return
		
# 	if run_status != RunStatus.STARTED:
# 		push_warning("KadokadeoDevKit: Starting recording without active session")
		
# 	#replay_recorder.start_recording()
# 	print("KadokadeoDevKit: Recording started")

#func stop_recording() -> ReplayData:
#	var replay_data = replay_recorder.stop_recording()
#	print("KadokadeoDevKit: Recording stopped - ", replay_data.get_frame_count(), " frames")
#	return replay_data

#func play_replay(replay_data: ReplayData) -> void:
#	if replay_data == null:
#		push_error("KadokadeoDevKit: Cannot play null replay")
#		return
		
#	replay_player.play_replay(replay_data)

#func is_recording() -> bool:
#	return replay_recorder.is_recording()

#func is_replaying() -> bool:
#	return replay_player.is_playing()

#func save_replay_to_file(replay_data: ReplayData, file_path: String) -> bool:
#	return replay_data.save_to_file(file_path)

#func load_replay_from_file(file_path: String) -> ReplayData:
#	var replay_data = ReplayData.new()
#	if replay_data.load_from_file(file_path):
#		return replay_data
#	return null

# === PRIVATE METHODS ===

# func _on_replay_finished() -> void:
# 	replay_finished.emit()
