extends StaticBody2D

const SPEED: float = 500.0
const FLOORS: int = 10
var travelling_to: int = 0

func get_floor_position(floor: int) -> float:
	var height = get_window().size.y
	return height
	#var usable_height = height - $CollisionShape2D.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var dy = (64 * (10 - travelling_to)) - position.y
	var distance = abs(dy)
	var direction = -sign(dy)
	if distance < 5 or travelling_to == 0:
		travelling_to = 0
	else:
		move_and_collide(direction * Vector2.UP * SPEED * delta)


func _on_elevator_buttons_call_elevator(floor: int) -> void:
	travelling_to = floor
