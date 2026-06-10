extends StaticBody2D

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

signal reached_floor(floor: int, direction: Direction)
signal reached_destination(floor: int)

const SPEED: float = 100.0
const FLOORS: int = 10
@onready var BOUNDS: Vector2 = $CollisionShape2D.get_shape().get_rect().size

var ups: int = 0b0_000_000_000
var downs: int = 0b0_000_000_000
var destinations: int = 0b0000000000

var current_floor: int
var direction: Direction = Direction.IDLE
var door: Door = Door.CLOSED

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
	pass

func closest_floor_direction() -> Direction:
	var next_floor: int = -1
	var closest_distance: int = INF
	for floor in range(1, FLOORS + 1):
		if (ups | downs | destinations) & (1 << (floor - 1)):
			var dist: int = abs(current_floor - floor)
			if dist < closest_distance:
				closest_distance = dist
				next_floor = floor
				break
	
	if next_floor == -1: # no floors
		return Direction.IDLE
	elif next_floor > current_floor:
		return Direction.UP
	elif next_floor < current_floor:
		return Direction.DOWN
	else: # same floor
		return Direction.IDLE

func remaining_floors_in(dir: Direction, from: int) -> bool:
	match dir:
		Direction.UP:
			return (ups | downs | destinations) >> from
		Direction.DOWN:
			return (ups | downs | destinations) & ((1 << from - 1) - 1)
		_: return false
			
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
	and (ups | downs | destinations) & (1 << (current_floor - 1)) \
	and (
		not remaining_floors_in(direction, current_floor)
		or (ups if direction == Direction.UP else downs) &
		   (1 << (current_floor - 1))
	):
		self.position.y = get_floor_position(current_floor)
		door = Door.OPENING
		$Timer.start_with_floor(current_floor)
	else:
		move_and_collide(Vector2(0, SPEED * delta * direction))

func _physics_process(delta: float) -> void:
	current_floor = get_floor(self.position.y)
	if door == Door.CLOSED:
		move(delta)

func _on_timer_on_floor_timeout(floor: int) -> void:
	door = Door.OPEN
	match direction:
		Direction.DOWN:
			if downs & (1 << (floor - 1)):
				downs ^= (1 << (floor - 1))
				reached_floor.emit(floor, Direction.DOWN)
			elif ups & (1 << (floor - 1)):
				ups ^= (1 << (floor - 1))
				reached_floor.emit(floor, Direction.UP)
		_:
			if ups & (1 << (floor - 1)):
				ups ^= (1 << (floor - 1))
				reached_floor.emit(floor, Direction.UP)
			elif downs & (1 << (floor - 1)):
				downs ^= (1 << (floor - 1))
				reached_floor.emit(floor, Direction.DOWN)
	
	if destinations & (1 << (floor - 1)):
		destinations ^= (1 << (floor - 1))
		reached_destination.emit(floor)
		direction = next_direction(floor)
		door = Door.CLOSED
	else:
		$"../DestinationFloorButtons".visible = true

func _on_elevator_buttons_call_elevator(floor: int, dir: Direction) -> void:
	match dir:
		Direction.UP: ups |= (1 << (floor - 1))
		Direction.DOWN: downs |= (1 << (floor - 1))
	if floor != current_floor:
		direction = next_direction(current_floor)

func _on_destination_floor_buttons_call_elevator(floor: int) -> void:
	$"../DestinationFloorButtons".visible = false
	destinations |= (1 << (floor - 1))
	direction = next_direction(current_floor)
	door = Door.CLOSED
