# Allow this script to execute in the editor.
@tool

# This script is attached to a container containing an
# Up call button, down call button, floor number label,
# and indicator (for when the floor is a destination).
extends HBoxContainer

# Floor number that the buttons are connected to.
@export var floor_number: int = 1

# Custom type (shared across multiple scripts) to represent
# a direction that the elevator could be travelling in.
enum Direction {
	UP = -1,
	IDLE = 0,
	DOWN = 1,
}

# Initialize the text and buttons by connecting them 
# to their proper floor number event handler.
func _ready() -> void:
	$Label.text = str(floor_number)
	$UpButton.pressed.connect(_on_button_pressed.bind(floor_number, Direction.UP))
	$DownButton.pressed.connect(_on_button_pressed.bind(floor_number, Direction.DOWN))

# Disable the floor button and send a "call_elevator" event
# when the button is pressed.
func _on_button_pressed(floor: int, direction: Direction) -> void:
	match direction:
		Direction.UP: $UpButton.disabled = true
		Direction.DOWN: $DownButton.disabled = true
	$"..".call_elevator.emit(floor, direction)
