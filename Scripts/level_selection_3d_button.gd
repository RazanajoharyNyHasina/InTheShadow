extends MeshInstance3D
class_name LevelSelection3DButton


@export var selected: bool = false : set = _set_selected, get = _get_selected;
@export var locked: bool = false : set = _set_locked, get = _get_locked;
@export var solved: bool = false : set = _set_solved, get = _get_solved;
@export var allowed_transform: UtilsFunction.AuthorizedTransform = UtilsFunction.AuthorizedTransform.ALL;
@export var axe_constraint: UtilsFunction.AxeConstraint = UtilsFunction.AxeConstraint.FREE;
@export var left_button: LevelSelection3DButton;
@export var right_button: LevelSelection3DButton;
@export_file var level_mesh_path: String;
@export var level_name: String = "Level Dummy";
@export var texture_2d: Texture2D;
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_3d: Sprite3D = $Sprite3D

@onready var label_3d: Label3D = $Label3D

func	_set_selected(value: bool) -> void:
	selected = value;
	set_instance_shader_parameter("are_selected", value);

func	_get_selected() -> bool:
	return selected;

func	_set_locked(value: bool) -> void:
	locked = value;
	if locked:
		visible = false;
	elif not locked:
		visible = true;
		if not solved:
			animation_player.play("animation_unlocked");
	set_instance_shader_parameter("are_locked", value);

func	_get_locked() -> bool:
	return locked;

func	_set_solved(value: bool) -> void:
	solved = value;
	sprite_3d.texture = GlobalVar.TEX_UNSOLVED_SELECTION_BUTTON if not value else texture_2d;

func	_get_solved() -> bool:
	return solved;

func	_ready() -> void:
	sprite_3d.texture = GlobalVar.TEX_UNSOLVED_SELECTION_BUTTON if not solved else texture_2d;
	label_3d.text = level_name;
