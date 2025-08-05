extends Node2D
class_name ApiClient

var base_url: String = ""
var timeout: float = 10.0
var http_request: HTTPRequest
var auth_token: String = ""
var is_ready: bool = false

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.timeout = timeout
	
	http_request.use_threads = true
	http_request.accept_gzip = true

	is_ready = true
	print("ApiClient ready")

func configure(server_url: String) -> void:
	base_url = server_url.rstrip("/")

func post_request(endpoint: String, data: Dictionary) -> ApiResponse:
	return await request(endpoint, data, HTTPClient.METHOD_POST)

func get_request(endpoint: String) -> ApiResponse:
	return await request(endpoint, {}, HTTPClient.METHOD_GET)

func request(endpoint: String, data: Dictionary, method: HTTPClient.Method) -> ApiResponse:
	# Attendre que l'ApiClient soit prêt
	if not is_ready:
		await get_tree().process_frame
		if not is_ready:
			return ApiResponse.fail("ApiClient not ready")
	
	var url = base_url + endpoint
	var json_string = JSON.stringify(data)
	var headers = PackedStringArray()
	
	headers.append("Content-Type: application/json")
	headers.append("Accept: application/json")
	
	if not auth_token.is_empty():
		headers.append("Authorization: Bearer " + auth_token)
	
	print("KadokadeoDevKit API: POST ", url)
	print("Data: ", json_string)
	
	var error = http_request.request(url, headers, method, json_string)
	if error != OK:
		var error_msg = "Failed to send request. Error: " + str(error)
		
		print("Request error: ", error_msg)
		return ApiResponse.fail(error_msg)

	var result = await http_request.request_completed
	
	var result_code: int = result[0]
	var response_code: int = result[1]
	var headers_response: PackedStringArray = result[2]
	var body: PackedByteArray = result[3]

	return _on_request_completed(result_code, response_code, headers_response, body)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> ApiResponse:
	if (result != OK):
		var error_msg: String = ""
		error_msg = "Result code: " + str(result)
		match result:
			HTTPRequest.RESULT_CANT_CONNECT:
				error_msg = "Cannot connect to host"
			HTTPRequest.RESULT_CANT_RESOLVE:
				error_msg = "Cannot resolve host"
			HTTPRequest.RESULT_CONNECTION_ERROR:
				error_msg = "Request failed due to connection (read/write) error"
			HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
				error_msg = "Request failed on TLS handshake"
		print("KadokadeoDevKit API: ", error_msg)
		return ApiResponse.fail(error_msg, response_code)
	
	if response_code >= 200 and response_code < 300:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			var response_data = json.data
			print("KadokadeoDevKit API: Success ", response_code)
			return ApiResponse.ok(response_data.data, response_code)
		else:
			return ApiResponse.fail("Failed to parse JSON response", response_code)

	var error_message = "HTTP Error " + str(response_code)
	
	# Essayer de parser le message d'erreur
	if body.size() > 0:
		var body_text = body.get_string_from_utf8()
		print("Error response body: ", body_text)
		
		var json = JSON.new()
		var parse_result = json.parse(body_text)
		
		if parse_result == OK and typeof(json.data) == TYPE_DICTIONARY and json.data.has("error"):
			error_message += ": " + str(json.data.error)
		else:
			error_message += ": " + body_text
	
	print("KadokadeoDevKit API: Error ", error_message)
	return ApiResponse.fail(error_message, response_code)
