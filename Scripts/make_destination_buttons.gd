@tool
extends GridContainer

@onready var font = load("res://Assets/monogram.ttf")

signal call_elevator(floor: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for floor in range(10):
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(48, 48)
		button.pressed.connect(_on_button_pressed.bind(10 - floor))
		
		var text: Label = Label.new()
		text.text = str(10 - floor)
		text.label_settings = LabelSettings.new()
		text.label_settings.font = font
		text.label_settings.font_size = 32
		text.label_settings.shadow_size = 2
		text.label_settings.shadow_offset = Vector2(2, 2)
		text.label_settings.shadow_color = Color.BLACK
		text.set_anchors_preset(Control.PRESET_FULL_RECT)
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		button.add_child(text)
		self.add_child(button)

func _on_button_pressed(floor: int) -> void:
	call_elevator.emit(floor)
