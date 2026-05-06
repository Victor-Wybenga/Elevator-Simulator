@tool
extends GridContainer

@onready var font = load("res://Assets/font.ttf")

signal call_elevator(floor: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for floor in range(10):
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(90, 90)
		button.text = str(10 - floor)
		button.add_theme_font_override("font", font)
		button.add_theme_font_size_override("font_size", 50)
		button.pressed.connect(_on_button_pressed.bind(10 - floor))
		add_child(button)

func _on_button_pressed(floor: int) -> void:
	get_child(10 - floor).disabled = true
	call_elevator.emit(floor)

func _on_elevator_reached_floor(floor: int) -> void:
	get_child(10 - floor).disabled = false
