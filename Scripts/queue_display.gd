extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.text = ("Queue: {queue}\nCurrent Floor: {floor}\nCurent State: {state}\nTarget Floor: {target}").format({
		"queue": ", ".join($"../Elevator".called_floors), 
		"floor": $"../Elevator".current_floor,
		"state": $"../Elevator".ElevatorState.find_key($"../Elevator".state),
		"target": $"../Elevator".target_floor
	})
