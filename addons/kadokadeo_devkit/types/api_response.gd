class_name ApiResponse

var success: bool
var data: Dictionary
var error: String = ""
var code: int = 0

# Success constructor
static func ok(data: Dictionary, code: int = 200) -> ApiResponse:
	var r = ApiResponse.new()
	r.success = true
	r.data = data
	r.code = code
	return r

# Error constructor
static func fail(error: String, code: int = 0) -> ApiResponse:
	var r = ApiResponse.new()
	r.success = false
	r.error = error
	r.code = code
	return r
