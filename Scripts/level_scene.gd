extends Node3D
class_name LevelScene

@export_file var level_mesh_path: String;
@export var hint: String;
@export var already_solved: bool = false;
@export var allowed_transform: UtilsFunction.AuthorizedTransform = UtilsFunction.AuthorizedTransform.ALL;
@export var allowed_axis: UtilsFunction.AxeConstraint = UtilsFunction.AxeConstraint.FREE;
@onready var mesh_placeholder: Node3D = $MeshPlaceholder;
@onready var shadow_spot_light: SpotLight3D = $ShadowSpotLight;
@onready var camera: Camera3D = $Camera3D;
@onready var shadow_viewport: SubViewport = $ShadowViewport;
@onready var shadow_placeholder: Node3D = $ShadowViewport/ShadowPlaceholder;
@onready var shadow_camera: Camera3D = $ShadowViewport/ShadowCamera;
@onready var animation_player: AnimationPlayer = $AnimationPlayer;
@onready var solved_menu: PanelContainer = $CanvasLayer/Menu/SolvedMenu;
@onready var control_hint_button: TextureButton = $CanvasLayer/ButtonContainer/HBoxContainer/ControlHintButton;
@onready var hint_button: TextureButton = $CanvasLayer/ButtonContainer/HBoxContainer/HintButton
@onready var control: CenterContainer = $CanvasLayer/Control;
@onready var darken_control_background: TextureRect = $CanvasLayer/DarkenControlBackground;

var are_dragging: bool = false;
var transform_type: UtilsFunction.TransformType = UtilsFunction.TransformType.ROTATION;
var axe_constraint: UtilsFunction.AxeConstraint = UtilsFunction.AxeConstraint.FREE;
var previous_mouse_position: Vector2;
var start_drag_position: Vector3;
var obj_start_position: Vector3;
var game_mesh_scene_node: LevelLogic;
var selected_mesh_index: int = 0;
var selected_mesh_rect: Rect2 = Rect2(0.0, 0.0, 0.0, 0.0);
var selected_mesh_plane: Plane;
var projector_texture: ImageTexture;

var user_ctrl: bool = false;
var solved: bool = false;
var is_capturing_shadow: bool = false;

const MATERIAL_BLACK_SHADOW: ShaderMaterial = preload("res://Materials/material_black_shadow.res");

func	_ready() -> void:
	shadow_camera.look_at(shadow_placeholder.global_position);

	var mesh_scene_resource: Resource = load(level_mesh_path);

	if mesh_scene_resource == null:
		printerr("level_scene.gd: _ready: failed to load mesh scene resource.");
		get_tree().quit(-1);
		return ;

	game_mesh_scene_node = mesh_scene_resource.instantiate();

	if game_mesh_scene_node == null: 
		printerr("level_scene.gd: _ready: failed to instantiate mesh scene.");
		get_tree().quit(-1);
		return ;

	mesh_placeholder.add_child(game_mesh_scene_node);
	$CanvasLayer/HintLabelContainer/Label.text = game_mesh_scene_node.hint;

	if game_mesh_scene_node.list_mesh.size() > 0:
		_change_selected_mesh(game_mesh_scene_node.list_mesh[selected_mesh_index]);

	# create a copy of the current mesh
	for i in game_mesh_scene_node.list_mesh.size():
		var source_mesh: MeshInstance3D = game_mesh_scene_node.list_mesh[i];
		var duplicated_mesh: MeshInstance3D = source_mesh.duplicate();

		duplicated_mesh.material_override = MATERIAL_BLACK_SHADOW;
		shadow_placeholder.add_child(duplicated_mesh);
		duplicated_mesh.global_transform = source_mesh.global_transform;

	await RenderingServer.frame_post_draw;

	var shadow_texture = shadow_viewport.get_texture().get_image();
	projector_texture = ImageTexture.create_from_image(shadow_texture);
	projector_texture.update(shadow_texture);
	shadow_spot_light.light_projector = projector_texture;

	animation_player.play("animation_in");
	animation_player.animation_finished.connect(
		func	start_game(anim_name: String) -> void:
			if not anim_name == "animation_in":
				return;
			user_ctrl = true;
	)

func	_sync_shadow_clones() -> void:
	for i in game_mesh_scene_node.list_mesh.size():
		shadow_placeholder.get_child(i).global_transform = (game_mesh_scene_node.list_mesh[i] as Node3D).global_transform;

var debug_preview: TextureRect = null;
func	_debug_toggle_preview() -> void:
	if debug_preview:
		return ;
	debug_preview = TextureRect.new();
	debug_preview.texture = shadow_viewport.get_texture();
	debug_preview.custom_minimum_size = Vector2(256, 256);
	debug_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;
	debug_preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;
	debug_preview.position = Vector2(16, 16);
	$CanvasLayer.add_child(debug_preview);

func _refresh_projector_texture() -> void:
	is_capturing_shadow = true

	await RenderingServer.frame_post_draw

	var shadow_image: Image = shadow_viewport.get_texture().get_image()

	if projector_texture != null:
		projector_texture.set_image(shadow_image)
	else:
		projector_texture = ImageTexture.create_from_image(shadow_image)

	shadow_spot_light.light_projector = projector_texture

	is_capturing_shadow = false

var debouncing_time_stamps: float = 0;
var first_enter: bool = true;
func	_process(delta: float) -> void:
	# sync shadow mesh and visual mesh transform
	_sync_shadow_clones();

	# refresh the projected shadow
	debouncing_time_stamps += delta

	if debouncing_time_stamps >= 0.05 and not is_capturing_shadow:
		debouncing_time_stamps = 0.0
		_refresh_projector_texture();

	if solved or not user_ctrl:
		return ;

	if are_dragging:
		if (transform_type == UtilsFunction.TransformType.ROTATION and
			(allowed_transform == UtilsFunction.AuthorizedTransform.ALL or
			allowed_transform == UtilsFunction.AuthorizedTransform.ROTATION)
		):
			if first_enter:
				# the first drag should have no effect, setting this prevent error drag value
				previous_mouse_position = get_viewport().get_mouse_position();
				first_enter = false;

			UtilsFunction._rotate_mesh_around_trackball(
				axe_constraint if allowed_axis == UtilsFunction.AxeConstraint.FREE else allowed_axis,
				game_mesh_scene_node.list_mesh[selected_mesh_index],
				previous_mouse_position,
				get_viewport().get_mouse_position(),
				selected_mesh_rect,
				shadow_spot_light,
				camera
			);
			# should not forget this
			previous_mouse_position = get_viewport().get_mouse_position();
		elif (transform_type == UtilsFunction.TransformType.TRANSLATION and
			(allowed_transform == UtilsFunction.AuthorizedTransform.ALL or
			allowed_transform == UtilsFunction.AuthorizedTransform.TRANSLATION)
		):
			UtilsFunction._translate_around_plane(
				axe_constraint if allowed_axis == UtilsFunction.AxeConstraint.FREE else allowed_axis,
				game_mesh_scene_node.list_mesh[selected_mesh_index],
				selected_mesh_plane,
				camera,
				obj_start_position,
				start_drag_position,
				get_viewport().get_mouse_position()
			);

	# check if all raycast collide to determine if it's solved or not
	if game_mesh_scene_node.are_solved():
		solved = true;
		solved_menu.visible = true;
		animation_player.play("animation_solved");
		control_hint_button.visible = false;
		if not GlobalVar.TEST_MODE and not already_solved:
			GlobalVar.unlocked_level_index += 1;
			GlobalVar.solved_level_index += 1;
			GlobalVar.save_lvl_data(GlobalVar.user_lvl_path);

func _change_selected_mesh(node: MeshInstance3D) -> void:
	node.set_instance_shader_parameter("are_selected", true);
	_update_selection_geometry(node);

func _update_selection_geometry(node: MeshInstance3D) -> void:
	selected_mesh_rect = UtilsFunction.compute_screen_rect(node, camera);
	selected_mesh_plane = Plane(-camera.global_basis.z, node.global_position);

var timestamps_check: float = Time.get_ticks_msec();
func	_input(event: InputEvent) -> void:
	if solved or not user_ctrl:
		return ;

	if event is InputEventKey:
		match event.keycode:
			KEY_SPACE:
				print("CurrentInfo: rot: ", game_mesh_scene_node.list_mesh[selected_mesh_index].rotation_degrees);
			KEY_F1:
				var shadow_texture: Image = shadow_viewport.get_texture().get_image()
				shadow_texture.save_png("user://shadow_debug.png")
			KEY_F2:
				_debug_toggle_preview();

	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
			transform_type = UtilsFunction.TransformType.ROTATION if event.button_index == MOUSE_BUTTON_LEFT else UtilsFunction.TransformType.TRANSLATION;
			if event.is_pressed() and selected_mesh_rect.has_point(get_viewport().get_mouse_position()):
				are_dragging = true;

				if transform_type == UtilsFunction.TransformType.TRANSLATION:
					var mesh: MeshInstance3D = game_mesh_scene_node.list_mesh[selected_mesh_index];
					selected_mesh_plane = Plane(-camera.global_basis.z, mesh.global_position);

					var hit: Variant = selected_mesh_plane.intersects_ray(
						camera.project_ray_origin(get_viewport().get_mouse_position()),
						camera.project_ray_normal(get_viewport().get_mouse_position())
					);
					if hit == null:
						return ;
					start_drag_position = hit;
					obj_start_position = mesh.global_position;

				if event.ctrl_pressed:
					axe_constraint = UtilsFunction.AxeConstraint.X_ONLY;
				elif event.shift_pressed:
					axe_constraint = UtilsFunction.AxeConstraint.Y_ONLY;
				elif event.alt_pressed:
					axe_constraint = UtilsFunction.AxeConstraint.Z_ONLY;
				else:
					axe_constraint = UtilsFunction.AxeConstraint.FREE;
				return ;
			elif not event.is_pressed() or not selected_mesh_rect.has_point(get_viewport().get_mouse_position()):
				are_dragging = false;
				selected_mesh_rect = UtilsFunction.compute_screen_rect(game_mesh_scene_node.list_mesh[selected_mesh_index], camera);
				first_enter = true;
				_update_selection_geometry(game_mesh_scene_node.list_mesh[selected_mesh_index]);
				return ;

		if ((Time.get_ticks_msec() - timestamps_check) / 1000) < 0.25:
			return ;

		timestamps_check = Time.get_ticks_msec();
		if game_mesh_scene_node.list_mesh.is_empty():
			return ;

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			game_mesh_scene_node.list_mesh[selected_mesh_index].set_instance_shader_parameter("are_selected", false);

			selected_mesh_index = wrap(selected_mesh_index + 1, 0, game_mesh_scene_node.list_mesh.size());
			_change_selected_mesh(game_mesh_scene_node.list_mesh[selected_mesh_index]);
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			game_mesh_scene_node.list_mesh[selected_mesh_index].set_instance_shader_parameter("are_selected", false);

			selected_mesh_index = wrap(selected_mesh_index - 1, 0, game_mesh_scene_node.list_mesh.size());
			_change_selected_mesh(game_mesh_scene_node.list_mesh[selected_mesh_index]);

func _on_back_pressed() -> void:
	animation_player.play("animation_out");
	animation_player.animation_finished.connect(
		func	_back_to_menu(anim_name: String):
			if not anim_name == "animation_out":
				return ;
			get_tree().change_scene_to_file("res://Scenes/play_menu_3d.tscn");
	);

var control_hint_panel_tweener: Tween;

func update_visibility_of_hint_panel(col: Color):
	control.modulate = col;
	darken_control_background.modulate = col;

func _on_control_hint_button_toggled(toggled_on: bool) -> void:
	control.visible = true;
	darken_control_background.visible = true;

	if control_hint_panel_tweener and control_hint_panel_tweener.is_running():
		control_hint_panel_tweener.kill();

	control_hint_panel_tweener = create_tween();
	control_hint_panel_tweener.tween_method(
		update_visibility_of_hint_panel,
		control.modulate,
		Color(1.0, 1.0, 1.0, 1.0) if toggled_on else Color(1.0, 1.0, 1.0, 0.0),
		0.25
	);

	control_hint_panel_tweener.finished.connect(
		func hide_or_show_hint_panel() -> void:
			control.visible = toggled_on;
			darken_control_background.visible = toggled_on;
	)
	set_process(!toggled_on);

func _on_back_button_pressed() -> void:
	animation_player.play("animation_out");
	animation_player.animation_finished.connect(
		func	_back_to_menu(anim_name: String):
			if not anim_name == "animation_out":
				return ;
			get_tree().change_scene_to_file("res://Scenes/play_menu_3d.tscn");
	);

func _on_hint_button_pressed() -> void:
	animation_player.play("display_hint_label");

func _on_quit_pressed() -> void:
	animation_player.play("animation_out");
	animation_player.animation_finished.connect(
		func	_quit(anim_name: String):
			if not anim_name == "animation_out":
				return ;
			get_tree().quit(0);
	);
