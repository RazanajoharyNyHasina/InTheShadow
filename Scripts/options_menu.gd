extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer;
@onready var render_quality: CustomOptionButton = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/RenderQuality;
@onready var langage: CustomOptionButton = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/Langage;
@onready var fullscreen: CustomCheckButton = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/Fullscreen;
@onready var music_volume: CustomHorizontalSlider = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/MusicVolume;

func	_ready() -> void:
	animation_player.play('animation_in');

	render_quality.default_id = GlobalVar.config_render_quality;
	langage.default_id = GlobalVar.global_available_lng.find(GlobalVar.config_lng);
	fullscreen.set_pressed_no_signal(GlobalVar.config_fullscreen);
	music_volume.h_slider_node.set_value_no_signal(GlobalVar.config_music_volume);

func	_on_back_pressed() -> void:
	animation_player.play("animation_out");
	animation_player.animation_finished.connect(
		func open_play_scene_menu(_anim_name: String):
			# save change
			GlobalVar.config_save_data(GlobalVar.user_config_path);
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	)

func	_on_custom_option_button_on_item_selected(id: int) -> void:
	var viewport_scale: float = 0.0;

	match id:
		0:
			viewport_scale = 1.0;
		1:
			viewport_scale = 0.75;
		2:
			viewport_scale = 0.5;
	get_viewport().scaling_3d_scale = viewport_scale;
	GlobalVar.config_render_quality = id;

func	_on_langage_on_item_selected(id: int) -> void:
	TranslationServer.set_locale(GlobalVar.global_available_lng[id]);
	GlobalVar.config_lng = GlobalVar.global_available_lng[id];

func _on_custom_check_button_toggled(toggled_on: bool) -> void:
	get_viewport().get_window().mode = Window.MODE_FULLSCREEN if toggled_on else Window.MODE_WINDOWED;
	GlobalVar.config_fullscreen = toggled_on;

func _on_custom_horizontal_slider_on_slider_value_changed(value: float) -> void:
	GlobalVar.config_music_volume = value;
	MusicManager.volume_linear = value / 100.0;
