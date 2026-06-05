extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.text = ("Requested: {queue}\nDestination: {destination}\nCurrent Floor: {floor}\nDirection: {state}\nDoor: {door}").format({
		"queue": ", ".join($"../Elevator".requested_floors), 
		"destination": ", ".join($"../Elevator".destination_floors),
		"floor": $"../Elevator".current_floor,
		"state": $"../Elevator".Direction.find_key($"../Elevator".direction),
		"door": $"../Elevator".Door.find_key($"../Elevator".door),
	})
