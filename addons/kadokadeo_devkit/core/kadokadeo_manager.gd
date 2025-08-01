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
var current_run_id: String = ""
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
var api_client: ApiClient
#var replay_recorder: ReplayRecorder
#var replay_player: ReplayPlayer
var loading_screen: Control
var is_initialized_flag: bool = false
var run_details: StartRunData

func _ready():
	name = "KadokadeoManager"
	set_process(false)
	api_client = ApiClient.new()
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
		var endpoint = "/api/runs/" + current_run_id
		api_client.post_request(endpoint, {
			# score, timestamp, ...
		})
		current_run_id = ""
		print("KadokadeoDevKit: Session ended")

# === REPLAY SYSTEM ===

func start_recording() -> void:
	if not is_initialized_flag:
		push_error("KadokadeoDevKit: Must initialize before recording")
		return
		
	if run_status != RunStatus.STARTED:
		push_warning("KadokadeoDevKit: Starting recording without active session")
		
	#replay_recorder.start_recording()
	print("KadokadeoDevKit: Recording started")

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

func _on_replay_finished() -> void:
	replay_finished.emit()

# Méthodes utilitaires pour les développeurs
func get_current_run_id() -> String:
	return current_run_id

func _handle_session_error(error: String) -> void:
	run_status = RunStatus.ERROR
