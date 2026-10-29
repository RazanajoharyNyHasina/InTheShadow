extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func	_ready() -> void:
	animation_player.play('animation_in');

func _on_play_pressed() -> void:
	animation_player.play("animation_out");
	animation_player.animation_finished.connect(
		func open_play_scene_menu(_anim_name: String):
			GlobalVar.TEST_MODE = false;
			get_tree().change_scene_to_file("res://Scenes/play_menu_3d.tscn")
	)

func _on_options_pressed() -> void:
	animation_player.play("animation_out");
	animation_player.animation_finished.connect(
		func open_options_scene_menu(_anim_name: String):
			get_tree().change_scene_to_file("res://Scenes/options_menu.tscn")
	)

func _on_quit_pressed() -> void:
	animation_player.play("animation_out");
	animation_player.animation_finished.connect(
		func quit_game(_anim_name: String):
			get_tree().quit(0);
	)

func _on_test_pressed() -> void:
	animation_player.play("animation_out");
	animation_player.animation_finished.connect(
		func open_test_scene_menu(_anim_name: String):
			GlobalVar.TEST_MODE = true;
			get_tree().change_scene_to_file("res://Scenes/play_menu_3d.tscn")
	)
