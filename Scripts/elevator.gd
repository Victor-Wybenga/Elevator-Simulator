extends StaticBody2D
enum ElevatorState {
	MOVING_UP = -1,
	IDLE = 0,
	MOVING_DOWN = 1,
	DOOR_OPENING = 2,
	DOOR_CLOSING = 3
}

const SPEED: float = 100.0
const FLOORS: int = 10

var called_floors: Array[int]
var current_floor: int
var target_floor: int
var state: ElevatorState = ElevatorState.IDLE

signal reached_floor(floor: int)

func get_floor(y_position: float) -> int:
	var height: float = get_viewport_rect().size.y
	var bound_height: float = $CollisionShape2D.get_shape().get_rect().size.y
	var usable_height: float = height - bound_height
	return round(FLOORS - (FLOORS / usable_height) * (y_position - (3 * bound_height / 4)))

func get_floor_position(floor: int) -> float:
	var height: float = get_viewport_rect().size.y
	var bound_height: float = $CollisionShape2D.get_shape().get_rect().size.y
	var usable_height: float = height - bound_height
	return (usable_height / FLOORS) * (FLOORS - floor) + (3 * bound_height / 4)

func _process(delta: float) -> void:
	match state:
		ElevatorState.DOOR_OPENING: $ColorRect.color = Color.GREEN
		ElevatorState.IDLE: $ColorRect.color = Color.YELLOW
		_: $ColorRect.color = Color.PURPLE

func move(delta: float):
	move_and_collide(Vector2(0, SPEED * delta * state))
	
	var on_floor: bool = abs(
		self.position.y - get_floor_position(current_floor)
		) <= SPEED * delta
	
	if on_floor and current_floor in called_floors:
		self.position.y = get_floor_position(current_floor)
		$Timer.start()
		state = ElevatorState.DOOR_OPENING

func _physics_process(delta: float) -> void:
	current_floor = get_floor(self.position.y)
	match state:
		ElevatorState.MOVING_DOWN: 
			target_floor = called_floors.min()
			move(delta)
		ElevatorState.MOVING_UP: 
			target_floor = called_floors.max()
			move(delta)

func _on_elevator_buttons_call_elevator(floor: int) -> void:
	called_floors.push_back(floor)
	if state == ElevatorState.IDLE:
		if floor > current_floor:
			state = ElevatorState.MOVING_UP
		elif floor < current_floor:
			state = ElevatorState.MOVING_DOWN
		else:
			state = ElevatorState.DOOR_OPENING
			$Timer.start()

func _on_timer_timeout() -> void:
	called_floors.erase(current_floor)
	reached_floor.emit(current_floor)
	if target_floor == current_floor:
		if   called_floors.is_empty(): state = ElevatorState.IDLE
		elif current_floor > called_floors.min(): state = ElevatorState.MOVING_DOWN
		elif current_floor < called_floors.min(): state = ElevatorState.MOVING_UP
		else:
			state = ElevatorState.DOOR_OPENING
			$Timer.start()
	elif target_floor > current_floor: state = ElevatorState.MOVING_UP
	elif target_floor < current_floor: state = ElevatorState.MOVING_DOWN
		

func _on_destination_floor_buttons_call_elevator(floor: int) -> void:
	called_floors.push_back(floor)
