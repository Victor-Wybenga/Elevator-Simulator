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

var current_floor: int
var called_floors: Array[int]
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

func move_to_floor(delta: float):
	if state in [ElevatorState.IDLE, ElevatorState.DOOR_OPENING, ElevatorState.DOOR_CLOSING]:
		return
	
	move_and_collide(
		Vector2(0, SPEED * delta * state)
	)
	#position = target
	if current_floor in called_floors:
		called_floors.erase(current_floor)
		reached_floor.emit(current_floor)
		state = ElevatorState.DOOR_OPENING
		$Timer.start()
		$ColorRect.color = Color.GAINSBORO



func _physics_process(delta: float) -> void:
	current_floor = get_floor(self.position.y)
	match state:
		ElevatorState.MOVING_DOWN:
			target_floor = called_floors.min()
		ElevatorState.MOVING_UP:
			target_floor = called_floors.max()
	move_to_floor(delta)


func _on_elevator_buttons_call_elevator(floor: int) -> void:
	called_floors.push_back(floor)
	if state == ElevatorState.IDLE:
		if floor > current_floor:
			state = ElevatorState.MOVING_UP
		elif floor < current_floor:
			state = ElevatorState.MOVING_DOWN


func _on_timer_timeout() -> void:
	if current_floor == target_floor:
		if called_floors.is_empty():
			state = ElevatorState.IDLE
		else:
			state *= -1
