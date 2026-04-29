extends StaticBody2D

const SPEED: float = 100.0
const FLOORS: int = 10

var target_floors: Array[int] = []

enum ElevatorState {
	IDLE,
	MOVING_UP,
	MOVING_DOWN,
	DOOR_OPENING,
	DOOR_CLOSING
}

signal reached_floor(floor: int)

func get_floor_position(floor: int) -> float:
	var height: float = get_viewport_rect().size.y
	var bound_height: float = $CollisionShape2D.get_shape().get_rect().size.y
	var usable: float = height - bound_height
	return (usable / FLOORS) * (10 - floor) + (3 * bound_height / 4)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func move_to_floor(delta: float):
	if not target_floors:
		return
	
	var target = Vector2(
		self.position.x, 
		get_floor_position(target_floors[0])
	)
	if position.distance_to(target) > SPEED * delta:
		move_and_collide(
			position.direction_to(target) * SPEED * delta
		)
	else:
		position = target
		var floor = target_floors.pop_front()
		reached_floor.emit(floor)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move_to_floor(delta)


func _on_elevator_buttons_call_elevator(floor: int) -> void:
	target_floors.push_back(floor)
