extends Label

var count: int = 0
var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer > 3.0:
		count = (count + 1) % 3
		self.text = "loading"
		for i in range(count):
			self.text += "."
