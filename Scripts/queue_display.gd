extends Label

@export var debug_info: bool = false

func _process(delta: float) -> void:
	# Update the text displayed on the left side of the screen
	# with some information about the elevator.
	# The Bitmasks are shown if debug_info is set to true.
	if debug_info:
		self.text = ("Up: {ups}\nDown: {downs}\nDestinations: {dests}\nCurrent Floor: {floor}\nDirection State: {state}\nDoor State: {door}").format({
			 "ups": String.num_int64($"../../Elevator".ups, 2).pad_zeros(10), 
			 "downs": String.num_int64($"../../Elevator".downs, 2).pad_zeros(10),
			 "dests": String.num_int64($"../../Elevator".destinations, 2).pad_zeros(10),
			"floor": $"../../Elevator".current_floor,
			"state": $"../../Elevator".Direction.find_key($"../../Elevator".direction),
			"door": $"../../Elevator".Door.find_key($"../../Elevator".door),
		})
	else:
		self.text = ("Current Floor: {floor}\nDirection State: {state}\nDoor State: {door}").format({
			"floor": $"../../Elevator".current_floor,
			"state": $"../../Elevator".Direction.find_key($"../../Elevator".direction),
			"door": $"../../Elevator".Door.find_key($"../../Elevator".door),
		})
