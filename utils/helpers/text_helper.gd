class_name TextHelper

static func format_dialogue(text: String, speaker_name: String = "") -> String:
	return "%s\"%s\"" % ["" if speaker_name.is_empty() else "%s: " % speaker_name, text]

## Return a string enclosed by Color bbcode tags.
static func format_color(text: String, color: Color) -> String:
	return "[color=%s]%s[/color]" % [color.to_html(), text]

## Returns a string with all of its bbcode tags removed.
static func strip_formatting(text: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	var text_without_tags = regex.sub(text, "", true)
	return text_without_tags


