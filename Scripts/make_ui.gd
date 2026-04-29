@tool
extends VBoxContainer

signal call_elevator(floor: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(10):
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(256, 48)
		button.text = str(10 - i)
		button.pressed.connect(_on_button_pressed.bind(button, 10 - i))
		add_child(button)

func _on_button_pressed(button: Button, id: int) -> void:
	button.disabled = true
	call_elevator.emit(id)

func _on_elevator_reached_floor(floor: int) -> void:
	get_child(10 - floor).disabled = false
