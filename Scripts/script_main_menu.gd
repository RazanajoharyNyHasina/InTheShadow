extends Node3D

@onready var normal_mode_node: VBoxContainer = $CanvasLayer/Container/MenuContainer/NormalMode
@onready var game_mode_node: VBoxContainer = $CanvasLayer/Container/MenuContainer/GameMode;
@onready var test_mode_node: VBoxContainer = $CanvasLayer/Container/MenuContainer/TestMode;
@onready var settings_node: VBoxContainer = $CanvasLayer/Container/MenuContainer/Settings;
@onready var menu_container_node: MarginContainer = $CanvasLayer/Container/MenuContainer;
@onready var black_screen_node: ColorRect = $CanvasLayer/BlackScreen;
@onready var animation_player: AnimationPlayer = $AnimationPlayer;
@onready var volumetric_fog: CheckButton = $CanvasLayer/Container/MenuContainer/Settings/VolumetricFog/VolumetricFog;
@onready var sound: CheckButton = $CanvasLayer/Container/MenuContainer/Settings/Sound/Sound;
@onready var world_environment: WorldEnvironment = $WorldEnvironment;
@onready var ssao: CheckButton = $CanvasLayer/Container/MenuContainer/Settings/SSAO/SSAO;
@onready var render_quality_option_button: OptionButton = $CanvasLayer/Container/MenuContainer/Settings/RenderQuality/RenderQualityOptionButton;
@onready var render_quality_label: Label = $CanvasLayer/Container/MenuContainer/Settings/RenderQuality/MarginContainer/RenderQualityLabel;
@onready var langage_label: Label = $CanvasLayer/Container/MenuContainer/Settings/Langage/MarginContainer/LangageLabel;
@onready var langage_option_button: OptionButton = $CanvasLayer/Container/MenuContainer/Settings/Langage/LangageOptionButton;
@onready var camera_3d: Camera3D = $Camera3D;
@onready var camera_target: Marker3D = $CameraTarget;

enum  MenuStatus { IN_MENU, IN_GAME };

var	current_status: MenuStatus = MenuStatus.IN_MENU;

@export var	user_control: bool = true;

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
	
	if target.get_child(0) is HBoxContainer:
		target.get_child(0).get_child(1).grab_focus();
	else:
		target.get_child(0).grab_focus();

func	_on_button_pressed(button: Button):
	if not user_control:
		return ;
	create_tween().tween_property(button, "scale", Vector2(0.95, 0.95), 0.1);
	match button.name:
		"Normal":
			open_menu_and_hide_others("NormalMode", normal_mode_node);
			animation_player.play("animation_camera_menu_to_mode");
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
		"CancelFromNormalMode":
			open_menu_and_hide_others("GameMode", game_mode_node);
			animation_player.play("animation_camera_menu_to_mode_backward");
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

func	_on_ssao_toggled(toggled: bool) -> void:
	world_environment.environment.ssao_enabled = toggled;

func _on_render_quality_change(idx: int) -> void:
	var value: float = 1.0;

	match idx:
		0:
			value = 1.0;
		1:
			value = 0.75;
		2:
			value = 0.5;

	get_viewport().scaling_3d_scale = value;

func	_on_langage_change(idx: int) -> void:
	const lng_array: Array[String] = ["en", "fr"];

	TranslationServer.set_locale(lng_array[idx]);

func	_save_current_state() -> void:
	var config: ConfigFile = ConfigFile.new();
	var err: Error = config.load("user://user_settings.cfg");

	if err != OK:
		_create_new_save();
		return ;

	config.set_value("Accessibility", "langage", langage_option_button.selected);
	config.set_value("Graphics", "volumetric_fog", world_environment.environment.volumetric_fog_enabled);
	config.set_value("Graphics", "ssao", world_environment.environment.ssao_enabled);
	config.set_value("Graphics", "render_quality", render_quality_option_button.selected);
	config.set_value("Sound", "enabled", sound.button_pressed);
	config.set_value("Accessibility", "langage", langage_option_button.selected);

	var err_save: Error = config.save("user://user_settings.cfg");
	if err_save != OK:
		push_error("Failed to save: status: ", error_string(err_save));

func	_create_new_save() -> void:
	var config: ConfigFile = ConfigFile.new();

	config.set_value("Accessibility", "langage", 0);

	config.set_value("Graphics", "volumetric_fog", true);
	world_environment.environment.volumetric_fog_enabled = true;
	volumetric_fog.set_pressed_no_signal(true);

	config.set_value("Graphics", "ssao", true);
	world_environment.environment.ssao_enabled = true;
	ssao.set_pressed_no_signal(true);

	config.set_value("Graphics", "render_quality", 1.0);
	get_viewport().scaling_3d_scale = 1.0;
	render_quality_option_button.selected = 0;

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

	var config_value: Variant = config.get_value("Accessibility", "langage");
	if typeof(config_value) == TYPE_INT:
		langage_option_button.selected = config_value;
		_on_langage_change(config_value);

	config_value = config.get_value("Graphics", "volumetric_fog");
	if typeof(config_value) == TYPE_BOOL:
		world_environment.environment.volumetric_fog_enabled = config_value;
		volumetric_fog.set_pressed_no_signal(config_value);

	config_value = config.get_value("Graphics", "ssao");
	if typeof(config_value) == TYPE_BOOL:
		world_environment.environment.ssao_enabled = config_value;
		ssao.set_pressed_no_signal(config_value);

	config_value = config.get_value("Graphics", "render_quality");
	if typeof(config_value) == TYPE_INT:
		render_quality_option_button.selected = config_value;
		_on_render_quality_change(config_value);

	config_value = config.get_value("Sound", "enabled");
	if typeof(config_value) == TYPE_BOOL:
		sound.set_pressed_no_signal(config_value);


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
	
	ssao.mouse_entered.connect(_on_button_hovered.bind(ssao));
	ssao.mouse_exited.connect(_on_button_blur.bind(ssao));
	ssao.toggled.connect(_on_ssao_toggled);

	render_quality_option_button.mouse_entered.connect(_on_button_hovered.bind(render_quality_option_button));
	render_quality_option_button.mouse_exited.connect(_on_button_blur.bind(render_quality_option_button));
	render_quality_option_button.item_selected.connect(_on_render_quality_change);
	
	langage_option_button.mouse_entered.connect(_on_button_hovered.bind(langage_option_button));
	langage_option_button.mouse_exited.connect(_on_button_blur.bind(langage_option_button));
	langage_option_button.item_selected.connect(_on_langage_change);
	
	render_quality_label.mouse_entered.connect(func tmp(): render_quality_option_button.grab_focus());
	langage_label.mouse_entered.connect(func tmp(): langage_option_button.grab_focus());

func	_process(_delta: float) -> void:
	pass;
