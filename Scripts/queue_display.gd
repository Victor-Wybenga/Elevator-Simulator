extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.text = ("Up: {ups}\nDown: {downs}\nDestinations: {dests}\nCurrent Floor: {floor}\nDirection: {state}\nDoor: {door}").format({
		"ups": String.num_int64($"../Elevator".ups, 2).pad_zeros(10), 
		"downs": String.num_int64($"../Elevator".downs, 2).pad_zeros(10),
		"dests": String.num_int64($"../Elevator".destinations, 2).pad_zeros(10),
		"floor": $"../Elevator".current_floor,
		"state": $"../Elevator".Direction.find_key($"../Elevator".direction),
		"door": $"../Elevator".Door.find_key($"../Elevator".door),
	})
