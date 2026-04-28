@tool
extends VBoxContainer

signal call_elevator(floor: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(10):
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(192, 48)
		button.text = str(10 - i)
		button.pressed.connect(_on_button_pressed.bind(10 - i))
		add_child(button)

func _on_button_pressed(id: int) -> void:
	call_elevator.emit(id)
	
