class_name SecurePayload

var payload: String
var key: String
var sign: String

func _init(_payload: String, _key: String, _sign: String) -> void:
	payload = _payload
	key = _key
	sign = _sign
