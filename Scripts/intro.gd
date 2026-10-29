extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var timestamps: float = Time.get_ticks_msec();

const main_menu_path: String = "res://Scenes/main_menu.tscn"
var loaded: bool = false

func	_ready() -> void:
	animation_player.play('animation_in');
	ResourceLoader.load_threaded_request(main_menu_path);

	# user data loading happens directly here
	var file: ConfigFile = ConfigFile.new();
	var status: Error = file.load(GlobalVar.user_config_path);

	if status != OK:
		push_warning("intro.gd: _ready: can't open save file, creating new one.");
		if not GlobalVar.config_save_data(GlobalVar.user_config_path):
			return ;
	else:
		# apply save configuration
		var result: Variant = file.get_value("Graphics", "render_quality", 0);
		GlobalVar.config_render_quality = result;
		match result:
			null:
				pass;
			0:
				get_viewport().scaling_3d_scale = 1.0;
			1:
				get_viewport().scaling_3d_scale = 0.5;
			2:
				get_viewport().scaling_3d_scale = 0.25;

		result = file.get_value("Graphics", "fullscreen", true);
		GlobalVar.config_fullscreen = result;
		get_viewport().get_window().mode = Window.MODE_FULLSCREEN if result else Window.MODE_WINDOWED;

		result = file.get_value("Accessibility", "lng", "en");
		GlobalVar.config_lng = result;
		TranslationServer.set_locale(result);
		
		result = file.get_value("Sound", "music_volume", 100.0);
		GlobalVar.config_music_volume = result;
		MusicManager.volume_linear = result / 100.0;
	
	# load level data
	var level_data: ConfigFile = ConfigFile.new();
	var status_level_data: Error = level_data.load_encrypted_pass(GlobalVar.user_lvl_path, GlobalVar.ENCRYPTION_KEY);

	if status_level_data != OK:
		push_warning("intro.gd: _ready: ERROR opening ", GlobalVar.user_lvl_path, " created dummy one.");
		GlobalVar.save_lvl_data(GlobalVar.user_lvl_path);
	else:
		var result: Variant = level_data.get_value("level", "unlocked_level_index", 0);
		GlobalVar.unlocked_level_index = result;

		result = level_data.get_value("level", "solved_level_index", -1);
		GlobalVar.solved_level_index = result;


func	go_to_main_menu() -> void:
	var scene: PackedScene = ResourceLoader.load_threaded_get(main_menu_path);

	if scene:
		get_tree().change_scene_to_packed(scene);
	else:
		push_error("intro.tscn: go_to_main_menu: FATAL_ERROR: can't instantiate ", main_menu_path);
		get_tree().quit(-1);

func	_process(_delta: float) -> void:
	if loaded:
		if (Time.get_ticks_msec() - timestamps) / 1000 > 5.0:
			animation_player.play("animation_out");
		return ;
	
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(main_menu_path);

	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		return ;
	elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		push_error("intro.tscn: _process: thread loading failure for ", main_menu_path);
		get_tree().quit(-1);
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		loaded = true;
