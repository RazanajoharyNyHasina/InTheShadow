extends Node3D

@onready var NormalMode: Button = $CanvasLayer/Container/MarginContainer/Gamemode/Normal;
@onready var GameModeNode: VBoxContainer = $CanvasLayer/Container/MarginContainer/Gamemode;

func	_on_button_hovered(button: Button):
	button.grab_focus();
	create_tween().tween_property(button, "scale", Vector2(1.05, 1.05), 0.1);

func	_on_button_blur(button: Button):
	create_tween().tween_property(button, "scale", Vector2(1.0, 1.0), 0.1);

func	_on_button_pressed(button: Button):
	create_tween().tween_property(button, "scale", Vector2(0.95, 0.95), 0.1);
	match button.name:
		"Normal":
			print("Normal Pressed");
		"Test":
			pass;
		"Options":
			pass;
		"Exit":
			get_tree().quit(0);

func	_on_button_down(button: Button):
	create_tween().tween_property(button, "scale", Vector2(0.95, 0.95), 0.1);

func	_ready() -> void:
	# Make this button grab focus for keyboard accessibility
	NormalMode.grab_focus();
	
	for child in GameModeNode.get_children():
		if child is Button:
			child.mouse_entered.connect(_on_button_hovered.bind(child));
			child.mouse_exited.connect(_on_button_blur.bind(child));
			child.pressed.connect(_on_button_pressed.bind(child));
			child.button_down.connect(_on_button_down.bind(child));
			child.button_up.connect(_on_button_blur.bind(child));
			child.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND;
		pass;
