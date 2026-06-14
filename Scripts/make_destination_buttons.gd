# Allow this script to execute in the editor.
@tool

# This script creates multiple Button objects and
# adds it to a vertical box container, to form the destination
# selection UI.
extends GridContainer

# Load the font for the buttons in.
@onready var font = load("res://Assets/monogram.ttf")

# Signal for when the destination buttons get pressed.
signal call_elevator(floor: int)

func _ready() -> void:
	# Create 10 buttons with labels for each floor,
	# binding the buttons to the _on_button_pressed event
	# handler, and then add them to the GridContainer.
	for floor in range(10):
		# Create the button, with custom settings.
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(48, 48)
		button.pressed.connect(_on_button_pressed.bind(10 - floor))
		
		# Create the text, with custom settings.
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
		
		# Add the text to the button, and then the button
		# to the GridContainer.
		button.add_child(text)
		self.add_child(button)

# Destination buttons event handler, emits the call elevator signal
# to be handled by the elevator's script.
func _on_button_pressed(floor: int) -> void:
	call_elevator.emit(floor)
