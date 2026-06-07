extends Node3D

@onready var NormalMode: Button = $CanvasLayer/Container/MenuContainer/GameMode/Normal;
@onready var GameModeNode: VBoxContainer = $CanvasLayer/Container/MenuContainer/GameMode;
@onready var NormalModeNode: VBoxContainer = $CanvasLayer/Container/MenuContainer/NormalMode;
@onready var TestModeNode: VBoxContainer = $CanvasLayer/Container/MenuContainer/TestMode;
@onready var SettingsNode: VBoxContainer = $CanvasLayer/Container/MenuContainer/Settings;
@onready var MenuContainerNode: MarginContainer = $CanvasLayer/Container/MenuContainer;

func	_on_button_hovered(button: Button):
	button.grab_focus();
	create_tween().tween_property(button, "scale", Vector2(1.05, 1.05), 0.1);

func	_on_button_blur(button: Button):
	create_tween().tween_property(button, "scale", Vector2(1.0, 1.0), 0.1);

func	open_menu_and_hide_others(menu_name: String, target: Node):
	for child in MenuContainerNode.get_children():
		if (child.name == menu_name):
			child.visible = true;
		else:
			child.visible = false;
	target.get_child(0).grab_focus();

func	_on_button_pressed(button: Button):
	create_tween().tween_property(button, "scale", Vector2(0.95, 0.95), 0.1);
	match button.name:
		"Normal":
			open_menu_and_hide_others("NormalMode", NormalModeNode);
		"Test":
			open_menu_and_hide_others("TestMode", TestModeNode);
		"Settings":
			open_menu_and_hide_others("Settings", SettingsNode);
		"Exit":
			get_tree().quit(0);
		"Level1":
			print("Level1 button pressed.");
		"Level2":
			pass;
		"Level3":
			pass;
		"CancelToGameMode":
			open_menu_and_hide_others("GameMode", GameModeNode);

func	_on_button_down(button: Button):
	create_tween().tween_property(button, "scale", Vector2(0.95, 0.95), 0.1);

func	_ready() -> void:
	# Make the first button grab focus fssor keyboard accessibility
	GameModeNode.get_child(0).grab_focus();
	
	for menuVerticalContainer in MenuContainerNode.get_children():
		for child in menuVerticalContainer.get_children():
			if child is Button:
				child.mouse_entered.connect(_on_button_hovered.bind(child));
				child.mouse_exited.connect(_on_button_blur.bind(child));
				child.pressed.connect(_on_button_pressed.bind(child));
				child.button_down.connect(_on_button_down.bind(child));
				child.button_up.connect(_on_button_blur.bind(child));
				child.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND;
