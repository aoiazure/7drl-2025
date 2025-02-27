class_name EActionResult extends RefCounted

# An alternate Action to be performed instead of the failed one.
var alternative: EAction
# Returns true if the Action was successful.
var succeeded: bool = true

var error_message: String = ""

func _init(success: bool, alt: EAction = null, _error_message: String = "") -> void:
	succeeded = success
	alternative = alt
	error_message = _error_message
