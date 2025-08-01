extends Node

class_name ReplayManager

var is_recording := false
var is_replaying := false
var initial_state := {}
var inputs := []
var frame := 0
var current_input_index := 0

func start_recording(state: Dictionary):
    is_recording = true
    initial_state = state
    inputs.clear()
    frame = 0

func record_input(input_data: Dictionary):
    if is_recording:
        inputs.append({
            "frame": frame,
            "inputs": input_data.duplicate(true)
        })

func stop_recording():
    is_recording = false

func export_replay() -> String:
    return JSON.stringify({
        "initial_state": initial_state,
        "inputs": inputs
    }, "\t")

func load_replay(json: String):
    var parsed = JSON.parse_string(json)
    if parsed:
        initial_state = parsed["initial_state"]
        inputs = parsed["inputs"]
        is_replaying = true
        current_input_index = 0
        frame = 0
    else:
        push_error("Invalid replay JSON")

func get_current_input() -> Dictionary:
    if is_replaying and current_input_index < inputs.size():
        var data = inputs[current_input_index]
        if data["frame"] == frame:
            current_input_index += 1
            return data["inputs"]
    return {}

func advance_frame():
    frame += 1