# Allow this script to execute in the editor.
@tool

# This script creates multiple CallButton objects and
# adds it to a vertical box container.
extends VBoxContainer

# Custom type (shared across multiple scripts) to represent
# a direction that the elevator could be travelling in.
enum Direction {
	UP = -1,
	IDLE = 0,
	DOWN = 1,
}

# Signal for when the call buttons get pressed.
signal call_elevator(floor: int, direction: Direction)

# Load the CallButton scene template
const CALL_BUTTON: PackedScene = preload("res://Scenes/call_button.tscn")

func _ready() -> void:
	# Instantiate 10 call buttons for 10 floors, set their
	# floor numbers, and add it to the VBox.
	for floor in range(10):
		var call = CALL_BUTTON.instantiate()
		call.floor_number = 10 - floor
		self.add_child(call)

# Responds to the elevator reaching the floor, by
# re-enabling the call buttons.
func _on_elevator_reached_floor(floor: int, direction: Direction) -> void:
	match direction:
		Direction.UP: 
			self.get_child(10 - floor).get_node("UpButton") \
				.disabled = false
		Direction.DOWN: 
			self.get_child(10 - floor).get_node("DownButton") \
				.disabled = false

# Set the Indicator text to either "*" or " ", when the destinations
# have been set/reached.
func _on_destination_floor_buttons_call_elevator(floor: int) -> void:
	self.get_child(10 - floor).get_node("Indicator").text = "*"

func _on_elevator_reached_destination(floor: int) -> void:
	self.get_child(10 - floor).get_node("Indicator").text = " "
