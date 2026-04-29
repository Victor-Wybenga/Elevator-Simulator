extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.text = ("Queue: %s\nCurrent Floor: %d\nCurent State: %s") % [
		" -> ".join($"../Elevator".called_floors), 
		$"../Elevator".current_floor,
		$"../Elevator".state
	]
