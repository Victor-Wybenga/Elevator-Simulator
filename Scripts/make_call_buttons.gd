@tool
extends GridContainer

@onready var font = load("res://Assets/font.ttf")

signal call_elevator(floor: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for floor in range(10):
		var up: Button = Button.new()
		up.custom_minimum_size = Vector2(50, 50)
		up.text = "\u2191"
		up.add_theme_font_override("font", font)
		up.add_theme_font_size_override("font_size", 25)
		up.pressed.connect(_on_button_pressed.bind(10 - floor))
		self.add_child(up)
		
		var text: Label = Label.new()
		text.custom_minimum_size = Vector2(50, 50)
		text.text = str(10 - floor)
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		text.add_theme_font_override("font", font)
		text.add_theme_font_size_override("font_size", 25)
		self.add_child(text)
		
		var down: Button = Button.new()
		down.custom_minimum_size = Vector2(50, 50)
		down.text = "\u2193"
		down.add_theme_font_override("font", font)
		down.add_theme_font_size_override("font_size", 25)
		#down.pressed.connect(_on_button_pressed.bind(10 - floor))
		self.add_child(down)

func _on_button_pressed(floor: int) -> void:
	self.get_child(3 * (10 - floor)).disabled = true
	call_elevator.emit(floor)

func _on_elevator_reached_floor(floor: int) -> void:
	self.get_child(3 * (10 - floor)).disabled = false
