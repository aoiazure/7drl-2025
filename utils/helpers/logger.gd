class_name Logger extends Node

static var instance: Logger

@export_range(1, 100, 1, "or_greater") var history_capacity: int = 30
@export var scroll: ScrollContainer
@export var log_container: Container

var logs: Array[String] = []

static func log(message: String, also_console: bool = false, console_only: bool = false) -> void:
	if also_console:
		print_rich("[Console] %s" % message)
	if console_only:
		return
	
	# No repeats
	if not instance.logs.is_empty() and instance.logs.back() == message:
		var _label: LoggerLabel = instance.log_container.get_child(instance.log_container.get_child_count() - 1)
		_label.count += 1
		return
	
	if instance.logs.size() >= instance.history_capacity:
		instance.logs.pop_front()
		instance.log_container.get_child(0).queue_free()
	
	instance.logs.append(message)
	var label:= LoggerLabel.new(message)
	instance.log_container.add_child(label)
	
	await label.get_tree().process_frame
	instance.scroll.scroll_vertical = int(instance.scroll.get_v_scroll_bar().max_value)

static func error(_error: String, console_only: bool = false) -> void:
	Logger.log(TextHelper.format_color(
		_error, ColorLookup.ERROR
	), true, console_only)


func toggle() -> void:
	scroll.visible = !scroll.visible

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"ui_focus_next"):
		toggle()

func _ready() -> void:
	instance = self
	
	if scroll:
		var invisible_scrollbar_theme = Theme.new()
		var empty_stylebox = StyleBoxEmpty.new()
		invisible_scrollbar_theme.set_stylebox("scroll", "VScrollBar", empty_stylebox)
		invisible_scrollbar_theme.set_stylebox("scroll", "HScrollBar", empty_stylebox)
		scroll.get_v_scroll_bar().theme = invisible_scrollbar_theme
		scroll.get_h_scroll_bar().theme = invisible_scrollbar_theme

class LoggerLabel extends RichTextLabel:
	var message: String
	var count: int = 1 :
		set(val):
			count = val
			if val > 1:
				self.text = "%s (x%s)" % [message, count]
	
	func _init(_message: String) -> void:
		self.add_theme_font_size_override("normal_font_size", 4)
		self.bbcode_enabled = true
		self.fit_content = true
		self.scroll_active = false
		self.autowrap_mode = TextServer.AUTOWRAP_WORD
		self.custom_minimum_size = Vector2i(100, 5)
		self.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		self.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		self.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		self.message = _message
		self.text = self.message
