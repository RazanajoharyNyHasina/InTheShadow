extends Node3D

@onready var normal_mode_node: Button = $CanvasLayer/Container/MenuContainer/GameMode/Normal;
@onready var game_mode_node: VBoxContainer = $CanvasLayer/Container/MenuContainer/GameMode;
@onready var test_mode_node: VBoxContainer = $CanvasLayer/Container/MenuContainer/TestMode;
@onready var settings_node: VBoxContainer = $CanvasLayer/Container/MenuContainer/Settings;
@onready var menu_container_node: MarginContainer = $CanvasLayer/Container/MenuContainer;
@onready var black_screen_node: ColorRect = $CanvasLayer/BlackScreen;
@onready var animation_player: AnimationPlayer = $AnimationPlayer;
@onready var volumetric_fog: CheckButton = $CanvasLayer/Container/MenuContainer/Settings/VolumetricFog/VolumetricFog;
@onready var sound: CheckButton = $CanvasLayer/Container/MenuContainer/Settings/Sound/Sound;
@onready var world_environment: WorldEnvironment = $WorldEnvironment;

func	_on_button_hovered(button: Button):
	button.grab_focus();
	create_tween().tween_property(button, "scale", Vector2(1.05, 1.05), 0.1);

func	_on_button_blur(button: Button):
	create_tween().tween_property(button, "scale", Vector2(1.0, 1.0), 0.1);

func	open_menu_and_hide_others(menu_name: String, target: Node):
	for child in menu_container_node.get_children():
		if (child.name == menu_name):
			child.visible = true;
		else:
			child.visible = false;
	target.get_child(0).grab_focus();

func	_on_button_pressed(button: Button):
	create_tween().tween_property(button, "scale", Vector2(0.95, 0.95), 0.1);
	match button.name:
		"Normal":
			open_menu_and_hide_others("normal_mode", normal_mode_node);
		"Test":
			open_menu_and_hide_others("TestMode", test_mode_node);
		"Settings":
			open_menu_and_hide_others("Settings", settings_node);
		"Exit":
			get_tree().quit(0);
		"Level1":
			print("Level1 button pressed.");
		"Level2":
			pass;
		"Level3":
			pass;
		"CancelToGameMode":
			open_menu_and_hide_others("GameMode", game_mode_node);
		"FromSettingsToGameMode":
			_save_current_state();
			open_menu_and_hide_others("GameMode", game_mode_node);

func	_on_button_down(button: Button):
	create_tween().tween_property(button, "scale", Vector2(0.95, 0.95), 0.1);

func	_on_volumetric_fog_toggled(toggled: bool) -> void:
	world_environment.environment.volumetric_fog_enabled = toggled;

func	_on_sound_toggled(_toggled: bool) -> void:
	pass;

func	_save_current_state() -> void:
	var config: ConfigFile = ConfigFile.new();
	var err: Error = config.load("user://user_settings.cfg");
	
	if err != OK:
		_create_new_save();
		return ;

	config.set_value("Accessibility", "langage", "en");
	config.set_value("Graphics", "volumetric_fog", world_environment.environment.volumetric_fog_enabled);
	config.set_value("Graphics", "windows_size", get_window().size);
	config.set_value("Sound", "enabled", sound.button_pressed);

	var err_save: Error = config.save("user://user_settings.cfg");
	if err_save != OK:
		push_error("Failed to save: status: ", error_string(err_save));

func	_create_new_save() -> void:
	var config: ConfigFile = ConfigFile.new();

	config.set_value("Accessibility", "langage", "en");
	config.set_value("Graphics", "volumetric_fog", true);
	world_environment.environment.volumetric_fog_enabled = true;
	volumetric_fog.set_pressed_no_signal(true);
	config.set_value("Graphics", "windows_size", Vector2i(1920,1080));
	config.set_value("Sound", "enabled", true);
	sound.set_pressed_no_signal(true);

	var err: Error = config.save("user://user_settings.cfg");

	if err != OK:
		print("Failed to save the file: status: ", error_string(err));

func	_read_save_state_and_apply() -> void:
	var config: ConfigFile = ConfigFile.new();
	var err: Error = config.load("user://user_settings.cfg");
	
	if err != OK:
		_create_new_save();
		return ;

	config.get_value("Accessibility", "langage"); # set the current langage

	var read_volumetric_fog: Variant = config.get_value("Graphics", "volumetric_fog");
	if typeof(read_volumetric_fog) == TYPE_BOOL:
		world_environment.environment.volumetric_fog_enabled = read_volumetric_fog;
		volumetric_fog.set_pressed_no_signal(read_volumetric_fog);

	var read_sound_status = config.get_value("Sound", "enabled");
	if typeof(read_sound_status) == TYPE_BOOL:
		sound.set_pressed_no_signal(read_sound_status);

func	_ready() -> void:
	# Make the first button grab focus for keyboard accessibility
	game_mode_node.get_child(0).grab_focus();

	_read_save_state_and_apply();

	animation_player.play("fade_in");

	for menuVerticalContainer in menu_container_node.get_children():
		for child in menuVerticalContainer.get_children():
			if child is Button:
				child.mouse_entered.connect(_on_button_hovered.bind(child));
				child.mouse_exited.connect(_on_button_blur.bind(child));
				child.pressed.connect(_on_button_pressed.bind(child));
				child.button_down.connect(_on_button_down.bind(child));
				child.button_up.connect(_on_button_blur.bind(child));
				child.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND;

	# connect checkButton
	volumetric_fog.mouse_entered.connect(_on_button_hovered.bind(volumetric_fog));
	volumetric_fog.mouse_exited.connect(_on_button_blur.bind(volumetric_fog));
	volumetric_fog.toggled.connect(_on_volumetric_fog_toggled);
	
	sound.mouse_entered.connect(_on_button_hovered.bind(sound));
	sound.mouse_exited.connect(_on_button_blur.bind(volumetric_fog));
	sound.toggled.connect(_on_sound_toggled);
