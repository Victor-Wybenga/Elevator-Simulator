@tool
extends HBoxContainer

enum Direction {
	UP = -1,
	IDLE = 0,
	DOWN = 1,
}

@onready var font = load("res://Assets/font.ttf")

var up_buttons = VBoxContainer.new()
var down_buttons = VBoxContainer.new()
var floor_labels = VBoxContainer.new()

signal call_elevator(floor: int, direction: Direction)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for floor in range(10):
		var up: Button = Button.new()
		up.custom_minimum_size = Vector2(50, 50)
		up.text = "\u2191"
		up.add_theme_font_override("font", font)
		up.add_theme_font_size_override("font_size", 25)
		up.pressed.connect(_on_button_pressed.bind(10 - floor, Direction.UP))
		up_buttons.add_child(up)
		
		var text: Label = Label.new()
		text.custom_minimum_size = Vector2(50, 50)
		text.text = str(10 - floor)
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		text.add_theme_font_override("font", font)
		text.add_theme_font_size_override("font_size", 25)
		floor_labels.add_child(text)
		
		var down: Button = Button.new()
		down.custom_minimum_size = Vector2(50, 50)
		down.text = "\u2193"
		down.add_theme_font_override("font", font)
		down.add_theme_font_size_override("font_size", 25)
		down.pressed.connect(_on_button_pressed.bind(10 - floor, Direction.DOWN))
		down_buttons.add_child(down)
	
	self.add_child(up_buttons)
	self.add_child(floor_labels)
	self.add_child(down_buttons)

func _on_button_pressed(floor: int, direction: Direction) -> void:
	match direction:
		Direction.UP: self.up_buttons.get_child(10 - floor).disabled = true
		Direction.DOWN: self.down_buttons.get_child(10 - floor).disabled = true
	call_elevator.emit(floor, direction)

func _on_elevator_reached_floor(floor: int, direction: Direction) -> void:
	match direction:
		Direction.UP: self.up_buttons.get_child(10 - floor).disabled = false
		Direction.DOWN: self.down_buttons.get_child(10 - floor).disabled = false
