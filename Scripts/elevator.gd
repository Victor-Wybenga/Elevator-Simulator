extends StaticBody2D

signal reached_floor(floor: int)

enum Direction {
	UP = -1,
	IDLE = 0,
	DOWN = 1,
}

enum Door {
	CLOSED = 0,
	OPENING = 1,
	OPEN = 2,
	CLOSING = 3
}

const SPEED: float = 100.0
const FLOORS: int = 10
@onready var BOUNDS: Vector2 = $CollisionShape2D.get_shape().get_rect().size

var requested_floors: Array[Direction]
var destination_floors: Array[bool]

var current_floor: int
var direction: Direction = Direction.IDLE
var door: Door = Door.CLOSED

func _ready() -> void:
	requested_floors.resize(FLOORS)
	requested_floors.fill(Direction.IDLE)
	
	destination_floors.resize(FLOORS)
	destination_floors.fill(Direction.IDLE)

func get_floor(y_position: float) -> int:
	var height: float = get_viewport_rect().size.y
	var floor_height: float = height / FLOORS
	var bound_height: float = BOUNDS.y / 2
	var adjusted_y_position = height - (y_position + bound_height)
	return ceil(adjusted_y_position / floor_height) + 1

func get_floor_position(floor: int) -> float:
	var height: float = get_viewport_rect().size.y
	var floor_height: float = height / FLOORS
	var bound_height: float = BOUNDS.y / 2
	return height - bound_height - (floor - 1) * floor_height

func _process(delta: float) -> void:
	match door:
		Door.OPENING: $ColorRect.color = Color.RED
		Door.OPEN: $ColorRect.color = Color.ORANGE
		Door.CLOSING: $ColorRect.color = Color.YELLOW
		_: $ColorRect.color = Color.BLACK

func closest_floor_direction() -> Direction:
	var next_floor = requested_floors.find_custom(
		func(x): return x != Direction.IDLE
	) + 1
	
	if next_floor <= 0: # no floors
		return Direction.IDLE
	elif next_floor > current_floor:
		return Direction.UP
	elif next_floor < current_floor:
		return Direction.DOWN
	else: # same floor
		return Direction.IDLE

func remaining_floors_in(dir: Direction, floor: int) -> bool:
	match dir:
		Direction.UP:
			return not requested_floors.slice(floor - 1).all(
				func(x): return x == Direction.IDLE
			)
		Direction.DOWN:
			return not requested_floors.slice(0, floor - 1).all(
				func(x): return x == Direction.IDLE
			)
		_:
			return false
			
func next_direction(floor: int) -> Direction:
	if remaining_floors_in(direction, floor):
		return direction
	else:
		return closest_floor_direction()

func move(delta: float):
	var on_floor: bool = abs(
		self.position.y - get_floor_position(current_floor)
		) <= (SPEED * delta)
	
	if on_floor \
	and requested_floors[current_floor - 1] != Direction.IDLE \
	and not (
		remaining_floors_in(direction, current_floor) 
		and requested_floors[current_floor - 1] != direction
	):	
		self.position.y = get_floor_position(current_floor)
		door = Door.OPEN
		$Timer.start_with_floor(current_floor)
	else:
		move_and_collide(Vector2(0, SPEED * delta * direction))

func _physics_process(delta: float) -> void:
	current_floor = get_floor(self.position.y)
	if door == Door.CLOSED:
		move(delta)

func _on_timer_on_floor_timeout(floor: int) -> void:
	reached_floor.emit(floor)
	requested_floors[floor - 1] = Direction.IDLE
	direction = next_direction(floor)
	door = Door.CLOSED
	#$"../DestinationFloorButtons".visible = true

func _on_elevator_buttons_call_elevator(floor: int) -> void:
	requested_floors[floor - 1] = Direction.UP
	direction = next_direction(current_floor)

#func _on_destination_floor_buttons_call_elevator(floor: int) -> void:
	#$"../DestinationFloorButtons".visible = false
	#if target_floor == current_floor:
		#if   called_floors.is_empty(): state = ElevatorState.IDLE
		#elif current_floor > called_floors.min(): state = ElevatorState.MOVING_DOWN
		#elif current_floor < called_floors.min(): state = ElevatorState.MOVING_UP
		#else:
			#state = ElevatorState.DOOR_OPENING
			#$Timer.start()
	#elif target_floor > current_floor: state = ElevatorState.MOVING_UP
	#elif target_floor < current_floor: state = ElevatorState.MOVING_DOWN
	#called_floors.push_back(floor)
