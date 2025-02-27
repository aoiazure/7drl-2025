class_name Logger extends Node

static var instance: Logger

@export_range(1, 100, 1, "or_greater") var history_capacity: int = 30
@export var scroll: ScrollContainer
@export var log_container: Container

var logs: Array[String] = []

static func log_message(message: String) -> void:
	print_rich("(temp logging) | %s" % message)
	return
	
	# No repeats
	if not instance.logs.is_empty() and instance.logs.back() == message:
		return
	
	if instance.logs.size() >= instance.history_capacity:
		instance.logs.pop_front()
		instance.log_container.get_child(0).queue_free()
	
	
	instance.logs.append(message)
	var label:= RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.custom_minimum_size = Vector2i(200, 18)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text = message
	instance.log_container.add_child(label)
	
	await label.get_tree().process_frame
	instance.scroll.scroll_vertical = int(instance.scroll.get_v_scroll_bar().max_value)

static func log_error(error: String) -> void:
	#log_message(TextHelper.format_color(
		#error, CLookup.ERROR
	#))
	print_rich(TextHelper.format_color(error, CLookup.ERROR))


func _ready() -> void:
	instance = self
