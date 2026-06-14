# A modification of the elevator's timer that keeps track
# of the floor that the timer was started from.
extends Timer

# Keep track of the floor that the timer was started from.
var floor: int

# Signal sent once the elevator is done OPENING.
signal on_floor_timeout(floor: int)

# Set the floor when the timer is started from elsewhere.
func start_with_floor(floor: int):
	self.floor = floor
	self.start()

# Stop the timer and send out a signal once the elevator
# is done opening.
func _on_timeout() -> void:
	self.stop()
	on_floor_timeout.emit(self.floor)
