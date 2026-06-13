@tool
extends VBoxContainer

signal call_elevator(floor: int, direction: Direction)

enum Direction {
	UP = -1,
	IDLE = 0,
	DOWN = 1,
}

const CALL_BUTTON: PackedScene = preload("res://Scenes/call_button.tscn")

func _ready() -> void:
	for floor in range(10):
		var call = CALL_BUTTON.instantiate()
		call.floor_number = 10 - floor
		self.add_child(call)

func _on_elevator_reached_floor(floor: int, direction: Direction) -> void:
	match direction:
		Direction.UP: 
			get_child(10 - floor).get_node("UpButton").disabled = false
		Direction.DOWN: 
			get_child(10 - floor).get_node("DownButton").disabled = false

func _on_destination_floor_buttons_call_elevator(floor: int) -> void:
	get_child(10 - floor).get_node("Indicator").text = "*"

func _on_elevator_reached_destination(floor: int) -> void:
	get_child(10 - floor).get_node("Indicator").text = " "
