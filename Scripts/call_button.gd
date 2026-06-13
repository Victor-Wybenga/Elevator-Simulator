@tool
extends HBoxContainer

@export var floor_number: int = 1

enum Direction {
	UP = -1,
	IDLE = 0,
	DOWN = 1,
}

func _ready() -> void:
	$Label.text = str(floor_number)
	$UpButton.pressed.connect(_on_button_pressed.bind(floor_number, Direction.UP))
	$DownButton.pressed.connect(_on_button_pressed.bind(floor_number, Direction.DOWN))
	
func _on_button_pressed(floor: int, direction: Direction) -> void:
	match direction:
		Direction.UP: $UpButton.disabled = true
		Direction.DOWN: $DownButton.disabled = true
	$"..".call_elevator.emit(floor, direction)
