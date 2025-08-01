class_name StartRunData

var run_id: String
var server_time: int
var contract_points: int
var contract_score: int

func _init(data: Dictionary) -> void:
	run_id = data.run_id
	server_time = data.server_time as int
	contract_points = data.contract_points as int
	contract_score = data.contract_score as int
