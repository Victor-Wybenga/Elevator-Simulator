extends StaticBody2D
enum ElevatorState {
	IDLE,
	MOVING_UP,
	MOVING_DOWN,
	DOOR_OPENING,
	DOOR_CLOSING
}

const SPEED: float = 100.0
const FLOORS: int = 10

var current_floor: int
var target_floor: int
var called_floors: Array[bool] = []
var state: ElevatorState

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

func _ready() -> void:
	state = ElevatorState.IDLE
	called_floors.resize(10)
	called_floors.fill(false)
	
func next_floor(current_floor: int) -> void:
	var found_above = called_floors.slice(current_floor).find(true) + 1
	var found_below = called_floors.slice(0, current_floor).find(true) + 1
	
	if found_above:
		if state == ElevatorState.MOVING_UP:
			target_floor = found_above
		else:
			state = ElevatorState.MOVING_DOWN
	elif found_below:
		if state == ElevatorState.MOVING_DOWN:
			target_floor = found_below
		else:
			state = ElevatorState.MOVING_UP
	else:
		state = ElevatorState.IDLE
	

func move_to_floor(delta: float):
	if state == ElevatorState.IDLE:
		return
	
	var target = Vector2(
		self.position.x, 
		get_floor_position(target_floor)
	)
	if position.distance_to(target) > SPEED * delta:
		move_and_collide(
			position.direction_to(target) * SPEED * delta
		)
	else:
		position = target
		state = ElevatorState.IDLE
		called_floors[target_floor - 1] = false
		reached_floor.emit(target_floor)
	

func _physics_process(delta: float) -> void:
	current_floor = get_floor(self.position.y)
	next_floor(current_floor)
	move_to_floor(delta)


func _on_elevator_buttons_call_elevator(floor: int) -> void:
	if floor > current_floor:
		state = ElevatorState.MOVING_UP
	elif floor < current_floor:
		state = ElevatorState.MOVING_DOWN
	else:
		state = ElevatorState.IDLE
		
	called_floors[floor - 1] = true
