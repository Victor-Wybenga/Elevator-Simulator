# Allow this script to execute in the editor.
@tool

# Gives the poster sprite a floor_number field, so that
# its text can be dynamically updated.
extends Node2D

@export var floor_number: int = 1

# Set the poster text to the given floor number.
func _ready() -> void:
	$FloorNumber.text = str(floor_number)
