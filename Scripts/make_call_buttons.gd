@tool
extends HBoxContainer

enum Direction {
	UP = -1,
	IDLE = 0,
	DOWN = 1,
}

@onready var font = load("res://Assets/monogram.ttf")

var up_buttons = VBoxContainer.new()
var down_buttons = VBoxContainer.new()
var floor_labels = VBoxContainer.new()
var indicators = VBoxContainer.new()

signal call_elevator(floor: int, direction: Direction)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for floor in range(10):
		var up: Button = Button.new()
		up.custom_minimum_size = Vector2(28, 28)
		up.text = " UP "
		up.add_theme_font_override("font", font)
		up.add_theme_font_size_override("font_size", 16)
		up.pressed.connect(_on_button_pressed.bind(10 - floor, Direction.UP))
		up_buttons.add_child(up)
		
		var text: Label = Label.new()
		text.custom_minimum_size = Vector2(28, 28)
		text.text = str(10 - floor)
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		text.label_settings = LabelSettings.new()
		text.label_settings.font = font
		text.label_settings.font_size = 16
		text.label_settings.shadow_size = 2
		text.label_settings.shadow_offset = Vector2(2, 2)
		text.label_settings.shadow_color = Color.BLACK
		floor_labels.add_child(text)
		
		var down: Button = Button.new()
		down.custom_minimum_size = Vector2(28, 28)
		down.text = "DOWN"
		down.add_theme_font_override("font", font)
		down.add_theme_font_size_override("font_size", 16)
		down.pressed.connect(_on_button_pressed.bind(10 - floor, Direction.DOWN))
		down_buttons.add_child(down)
		
		var indicator: Label = Label.new()
		indicator.custom_minimum_size = Vector2(28, 28)
		indicator.text = " "
		indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		indicator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		indicator.label_settings = LabelSettings.new()
		indicator.label_settings.font = font
		indicator.label_settings.font_color = Color.RED
		indicator.label_settings.font_size = 16
		indicator.label_settings.shadow_size = 2
		indicator.label_settings.shadow_offset = Vector2(2, 2)
		indicator.label_settings.shadow_color = Color.BLACK
		indicators.add_child(indicator)
	
	self.add_child(up_buttons)
	self.add_child(floor_labels)
	self.add_child(down_buttons)
	self.add_child(indicators)

func _on_button_pressed(floor: int, direction: Direction) -> void:
	match direction:
		Direction.UP: self.up_buttons.get_child(10 - floor).disabled = true
		Direction.DOWN: self.down_buttons.get_child(10 - floor).disabled = true
	call_elevator.emit(floor, direction)

func _on_elevator_reached_floor(floor: int, direction: Direction) -> void:
	match direction:
		Direction.UP: self.up_buttons.get_child(10 - floor).disabled = false
		Direction.DOWN: self.down_buttons.get_child(10 - floor).disabled = false

func _on_destination_floor_buttons_call_elevator(floor: int) -> void:
	self.indicators.get_child(10 - floor).text = "*"

func _on_elevator_reached_destination(floor: int) -> void:
	self.indicators.get_child(10 - floor).text = " "
