extends Node3D

@export var camera_speed: float = 2.0;
@onready var animation_player: AnimationPlayer = $AnimationPlayer;
@onready var camera_3d: Camera3D = $Camera3D;
@onready var active_button: LevelSelection3DButton = $LevelButton/Elephant;
@onready var backButton: MainButton = $CanvasLayer/MarginContainer/Back;
@onready var level_button: Node3D = $LevelButton;

var focus_on_level_button: bool = true;
var user_ctrl: bool = false;

func	_ready() -> void:
	# remove focus from this node
	backButton.release_focus();
	animation_player.play("animation_in");
	animation_player.animation_finished.connect(
		func start_listening_to_player_ctrl(anim_name: String):
			if not anim_name == "animation_in":
				return ;
			user_ctrl = true;
	)
	
	var found_button: bool = false;

	for i in level_button.get_child_count():
		var level: LevelSelection3DButton = level_button.get_child(i);

		# make every level available in TEST MODE
		if GlobalVar.TEST_MODE:
			level.solved = true;
			level.locked = false;
			continue ;

		if i == GlobalVar.unlocked_level_index:
			active_button = level;
			active_button.set_instance_shader_parameter("are_selected", true);
			camera_3d.global_position.x = level.global_position.x;
			found_button = true;

		if i > GlobalVar.unlocked_level_index:
			level.solved = false;
			level.locked = true;
		else:
			level.solved = (i <= GlobalVar.solved_level_index);
			level.locked = false;
	if not found_button:
		active_button.set_instance_shader_parameter("are_selected", true);

func	_process(delta: float) -> void:
	if not is_equal_approx(camera_3d.global_position.x, active_button.global_position.x):
		camera_3d.global_position.x = lerp(
			camera_3d.global_position.x,
			active_button.global_position.x,
			delta * camera_speed
		);

func	_input(event: InputEvent) -> void:
	if not user_ctrl:
		return ;
	if event is InputEventKey:
		if event.is_action_pressed("ui_down"):
			backButton.call_deferred("grab_focus");
			active_button.selected = false;
			focus_on_level_button = false;
			return ;
		if event.is_action_pressed("ui_up"):
			backButton.call_deferred("release_focus");
			focus_on_level_button = true;
			active_button.selected = true;
			return 
		if not focus_on_level_button:
			return ;
		if event.is_action_pressed("ui_accept"):
			animation_player.play("animation_out");
			user_ctrl = false;
			animation_player.animation_finished.connect(
				func open_level(anim_name: String):
					if not anim_name == "animation_out":
						return ;
					var level_node: LevelScene = GlobalVar.LEVEL_SCENE_RESOURCE.instantiate();
					
					if level_node == null:
						printerr("level_selection_button.gd: _open_level: failed to instantiate scene level");
						get_tree().quit(-1);
						return ;
					level_node.level_mesh_path = active_button.level_mesh_path;
					level_node.already_solved = active_button.solved;
					level_node.allowed_transform = active_button.allowed_transform;
					level_node.allowed_axis = active_button.axe_constraint;
					get_tree().change_scene_to_node(level_node);
			)
			return ;
		if event.is_action_pressed("ui_left"):
			if active_button.left_button.locked:
				return ;

			active_button.selected = false;
			active_button = active_button.left_button;
			active_button.selected = true;
		if event.is_action_pressed("ui_right"):
			if active_button.right_button.locked:
				return ;

			active_button.selected = false;
			active_button = active_button.right_button;
			active_button.selected = true;

func _on_back_pressed() -> void:
	animation_player.play("animation_out");
	animation_player.animation_finished.connect(
		func back_to_main_menu(anim_name: String):
			if not anim_name == "animation_out":
				return ;
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn");
	)

func _on_back_mouse_entered() -> void:
	backButton.call_deferred("grab_focus");
	active_button.selected = false;
	focus_on_level_button = false;
