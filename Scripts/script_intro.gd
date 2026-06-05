extends Control

const			SceneMainMenu: String = "res://Scenes/scene_main_menu.tscn";
@onready var	NodeLabel: Label = $CenterContainer/VBoxContainer/Label;
@onready var	NodeAnimationPlayer: AnimationPlayer = $AnimationPlayer;
var				Done: bool = false;
var				AnimTimeFadeIn: int = 0;
var				TimeStamps: int = Time.get_ticks_msec();

func _on_animation_finished(_anim_name: String):
	match _anim_name:
		"anim_fade_in":
			AnimTimeFadeIn += 1;
		"anim_fade_out":
			var scene: PackedScene = ResourceLoader.load_threaded_get(SceneMainMenu);
			get_tree().change_scene_to_packed(scene);

func _ready() -> void:
	ResourceLoader.load_threaded_request(SceneMainMenu);
	NodeLabel.text = "0%";
	NodeAnimationPlayer.animation_finished.connect(_on_animation_finished);

func _process(_delta: float) -> void:
	if not Done:
		var progress: Array = [];
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(SceneMainMenu, progress);

		NodeLabel.text = str(progress[0] * 100) + "%";
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				if (AnimTimeFadeIn > 0 and Time.get_ticks_msec() - TimeStamps >= 5000):
					NodeAnimationPlayer.play("anim_fade_out");
					Done = true;
			ResourceLoader.THREAD_LOAD_FAILED:
				printerr("script_intro.gd: ResourceLoader.THREAD_LOAD_FAILED: failed to load main menu scene");
				get_tree().quit(1);
