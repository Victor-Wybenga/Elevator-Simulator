extends Timer

var floor: int

signal on_floor_timeout(floor: int)

func start_with_floor(floor: int):
	self.floor = floor
	self.start()

func _on_timeout() -> void:
	self.stop()
	on_floor_timeout.emit(self.floor)
