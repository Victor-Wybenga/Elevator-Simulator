@tool
extends Node2D

@export var floor_number: int = 1

func _ready() -> void:
	$FloorNumber.text = str(floor_number)
