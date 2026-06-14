extends StaticBody2D

# Possible elevator Direction states.
enum Direction {
	UP = -1,
	IDLE = 0,
	DOWN = 1,
}

# Possible elevator Door states.
enum Door {
	CLOSED = 0,
	OPENING = 1,
	OPEN = 2,
	CLOSING = 3
}

# Signals emitted once the elevator has reached a floor
# or one of the floors marked as a "destination" floor.
signal reached_floor(floor: int, direction: Direction)
signal reached_destination(floor: int)

# Constants for elevator
const SPEED: float = 100.0
const FLOORS: int = 10
@onready var BOUNDS: Vector2 = $CollisionShape2D.get_shape().get_rect().size

# Bitmasks used to store whether each of the floors are
# have been called with an up direction, a down direction,
# or a destination setting.
# Each floor is represented by one bit.
# i.e. ups = 0b0010000010 means
# that the 8th and 2nd floors have "UP" requests.
var ups: int = 0b0000000000
var downs: int = 0b0000000000
var destinations: int = 0b0000000000

# Keep track of the current floor and current direction
# and door states.
var current_floor: int
var direction: Direction = Direction.IDLE
var door: Door = Door.CLOSED

# Get which floor the elevator is on based on its current
# y-position. 
func get_floor(y_position: float) -> int:
	var height: float = get_viewport_rect().size.y
	var floor_height: float = 2 * height / FLOORS
	var bound_height: float = BOUNDS.y / 2
	var adjusted_y_position = height - (y_position + bound_height)
	return ceil(adjusted_y_position / floor_height) + 1

# Get which y-position represents the bottom of a specific
# floor (mathematical inverse function of `get_floor`).
func get_floor_position(floor: int) -> float:
	var height: float = get_viewport_rect().size.y
	var floor_height: float = 2 * height / FLOORS
	var bound_height: float = BOUNDS.y / 2
	return height - bound_height - (floor - 1) * floor_height

# Handle visual processing (animation frames) based on
# the elevator's door state.
func _process(_delta: float) -> void:
	match door:
		Door.CLOSED: $AnimatedSprite2D.frame = 0
		Door.OPENING: $AnimatedSprite2D.play("door")
		Door.OPEN: $AnimatedSprite2D.frame = 4
		Door.CLOSING: $AnimatedSprite2D.play_backwards("door")

# Determine which direction the closest called floor is in. 
func closest_floor_direction() -> Direction:
	# Keep track of the closest floor and distance.
	var closest_floor: int = -1
	var closest_distance: int = INF
	for floor in range(1, FLOORS + 1):
		# OR the up, down, and destinations together and
		# compare it with the number 1, shifted left by the
		# floor number, in order to check a specific bit.
		# i.e. 1001000100 (up | down | destinations)
		#    & 0001000000 (1 << 7)
		#    = 0001000000 (TRUE)
		#    therefore, there is a bit at position 7.
		if (ups | downs | destinations) & (1 << (floor - 1)):
			# If that bit is closer than the closest floor,
			# set the closest floor to it.
			var dist: int = abs(current_floor - floor)
			if dist < closest_distance:
				closest_distance = dist
				closest_floor = floor
	
	# No floors found.
	if closest_floor == -1:
		return Direction.IDLE
	# Closest floor is above.
	elif closest_floor > current_floor:
		return Direction.UP
	# Closest floor is below.
	elif closest_floor < current_floor:
		return Direction.DOWN
	# Same floor as current floor.
	else:
		return Direction.IDLE

# Determine if there are remaining floors in a direction.
func remaining_floors_in(dir: Direction, from: int) -> bool:
	match dir:
		Direction.UP:
			# Shift over all the bits so that the only ones that remain
			# are the ones representing above the floor.
			# i.e. 1000100010 (ups | downs | destinations)
			#   >> 7          (from) (floor number)
			#    = 100        (TRUE)
			return (ups | downs | destinations) >> from
		Direction.DOWN:
			# AND a bitmask filled with 1s below the current
			# floor.
			# i.e. 1000100010 (ups | downs | destinations)
			#    & 0000111111 ((1 << (7 - 1)) - 1) (bitmask)
			#    = 0000100010 (TRUE)
			return (ups | downs | destinations) & ((1 << from - 1) - 1)
		Direction.IDLE, _:
			# There are no remaining floors in the "IDLE" direction.
			return false

# Determine the next direction the elevator should go in.
func next_direction(floor: int) -> Direction:
	# If there are still floors remaining in the direction
	# that the elevator is travelling, keep going.
	if remaining_floors_in(direction, floor):
		return direction
	# If not, go in the direction of the closest floor.
	else:
		return closest_floor_direction()

# Determine how the elevator should move.
func move(delta: float):
	# Determine if the elevator is ON a floor by 
	# determining if the distance to its closest floor 
	# is below its per-frame speed.
	var on_floor: bool = abs(
		self.position.y - get_floor_position(current_floor)
		) <= (SPEED * delta)
	
	var call_on_current_floor: bool = \
		(ups | downs | destinations) \
		& (1 << (current_floor - 1))
		
	var no_floors_ahead: bool = \
		not remaining_floors_in(direction, current_floor)
	
	var called_floor_in_same_direction: bool = (
		ups | destinations 
		if direction == Direction.UP 
		else downs | destinations
	) & (1 << (current_floor - 1))
	
	# Stop on the floor if the elevator is on a floor, 
	# there is a call on the current floor,
	# and if there are no more floors ahead (should turn around),
	# or if the called floor is in the same direction the elevator
	# is travelling.
	if on_floor and call_on_current_floor \
	and (no_floors_ahead or called_floor_in_same_direction):
		# Snap the elevator to the floor's position, and open
		# the elevator door.
		self.position.y = get_floor_position(current_floor)
		door = Door.OPENING
		$Timer.start_with_floor(current_floor)
	# Otherwise, move like usual
	else:
		move_and_collide(Vector2(0, SPEED * delta * direction))

# Every frame, update the current floor, and move the elevator
# if the door is closed.
func _physics_process(delta: float) -> void:
	current_floor = get_floor(self.position.y)
	if door == Door.CLOSED:
		move(delta)

# Handle once the door is done opening.
func _on_timer_on_floor_timeout(floor: int) -> void:
	door = Door.OPEN
	# Determine if the elevator was called from the up button
	# and/or the bottom button.
	var down_called = downs & (1 << (floor - 1))
	var up_called = ups & (1 << (floor - 1))
	match direction:
		Direction.DOWN:
			# Check the down button first if the elevator is
			# heading downward, and send a reached floor signal.
			# Zero out the bit at that location.
			if down_called:
				downs ^= (1 << (floor - 1))
				reached_floor.emit(floor, Direction.DOWN)
			# Otherwise check the up button.
			elif up_called:
				ups ^= (1 << (floor - 1))
				reached_floor.emit(floor, Direction.UP)
		# Order of checks is reversed for UP and IDLE checks.
		Direction.UP, Direction.IDLE:
			if up_called:
				ups ^= (1 << (floor - 1))
				reached_floor.emit(floor, Direction.UP)
			elif down_called:
				downs ^= (1 << (floor - 1))
				reached_floor.emit(floor, Direction.DOWN)
	
	# If the floor arrived to is ONLY a destination, skip
	# the destination selector UI.
	if destinations & (1 << (floor - 1)) \
	and not up_called and not down_called:
		# Zero out that destination, send a signal that
		# the destination has been reached, and start closing
		# the door.
		destinations ^= (1 << (floor - 1))
		reached_destination.emit(floor)
		direction = next_direction(floor)
		door = Door.CLOSING
		$ClosingTimer.start()
	else:
		# If not, display the UI.
		$"../UI/DestinationFloorButtons".visible = true

# Responds to the elevator call buttons being pressed.
func _on_elevator_buttons_call_elevator(floor: int, dir: Direction) -> void:
	match dir:
		# Set the corresponding bit in the ups/downs bitmask.
		Direction.UP: ups |= (1 << (floor - 1))
		Direction.DOWN: downs |= (1 << (floor - 1))
	# Make the elevator update its direction when a new button has
	# been pressed.
	if floor != current_floor:
		direction = next_direction(current_floor)

# Responds to when the destination selector UI has been
# interacted with.
func _on_destination_floor_buttons_call_elevator(floor: int) -> void:
	# Hide the UI, set the destination bit in the
	# destinations bitmask, and start closing the door.
	$"../UI/DestinationFloorButtons".visible = false
	destinations |= (1 << (floor - 1))
	direction = next_direction(current_floor)
	door = Door.CLOSING
	$ClosingTimer.start()

# Once the closing timer has ended, set the door
# to CLOSED.
func _on_closing_timer_timeout() -> void:
	$ClosingTimer.stop()
	door = Door.CLOSED
