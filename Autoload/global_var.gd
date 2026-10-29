extends Node

# current config
var		config_render_quality: int = 0;
var		config_fullscreen: bool = true;
var		config_lng: String = "en";
var		config_music_volume: float = 100;

const	global_available_lng: Array[String] = ["en", "fr"];
const	user_config_path: String = "user://config.cfg";
const	user_lvl_path: String = "user://lvl.dt";

var		unlocked_level_index: int = 0;
var		solved_level_index: int = -1;

var		TEST_MODE: bool = false;
var		level_authorized_transform: UtilsFunction.AuthorizedTransform = UtilsFunction.AuthorizedTransform.ALL;
var		level_axis_limitation: UtilsFunction.AxeConstraint = UtilsFunction.AxeConstraint.FREE;

const	LEVEL_SCENE_RESOURCE = preload("res://Scenes/level_scene.tscn");
const	ENCRYPTION_KEY = "lksajdkladj-asd2ioh1o4h-14h1h41h4oh-7383642adas-wddiasdhada-shdasdhjahihxb-h1iuhiuhi4ug1iug41ig-b24g1-4b-bg41b4bbg4yybgyxbgy-1b4yb2yg4y2gb4ybg21ygb4y1bj4bgjyg-b1k2j4gj24bgkjgb4y1b4g-jhhsghjasgdhjgasjdgadwydgawasdkwdbuagdbuya-asdj";
const	TEX_UNSOLVED_SELECTION_BUTTON = preload("uid://dyesupo2h5wtw")


func	config_save_data(path: String) -> bool:
	var file = ConfigFile.new();

	file.set_value("Graphics", "render_quality", config_render_quality);
	file.set_value("Graphics", "fullscreen", config_fullscreen);
	file.set_value("Accessibility", "lng", config_lng);
	file.set_value("Sound", "music_volume", config_music_volume);

	var status: Error = file.save(path);
	if status != OK:
		push_error("global_var.gd: config_save_data(): file.save(path) returned ", status);
		get_tree().quit(-1);
		return false;
	return true;

func	save_lvl_data(path: String) -> bool:
	var file = ConfigFile.new();

	file.set_value("level", "unlocked_level_index", unlocked_level_index);
	file.set_value("level", "solved_level_index", solved_level_index);

	var status: Error = file.save_encrypted_pass(path, ENCRYPTION_KEY);
	if status != OK:
		push_error("global_var.gd: save_lvl_data(): file.save_encrypted_pass() returned", status);
		get_tree().quit(-1);
		return false;
	return true;
