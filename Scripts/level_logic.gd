extends Node3D
class_name LevelLogic

@export var list_mesh: Array[MeshInstance3D] = [];
@export var list_raycast: Array[RayCast3D] = [];
@export var position_checker: Area3D = null;
@export var start_angle_addition: Array[Vector3] = [];
@export var hint: String;
var target_rotation: Array[Vector3];
var solved: bool;
var solved_timestamps: int = 0;

func	are_solved() -> bool:
	var score_rotation: int = 0;
	var score_position: bool = false;

	for raycast: RayCast3D in list_raycast:
		if raycast.is_colliding():
			score_rotation += 1;

	if position_checker == null:
		score_position = true;
	else:
		score_position = position_checker.has_overlapping_bodies();
	
	solved = score_rotation == list_raycast.size() and score_position;
	if solved:
		solved_timestamps = Time.get_ticks_msec();
	return solved;

func	_ready() -> void:
	if list_mesh.size() != start_angle_addition.size():
		printerr("level_logic.gd: _ready: list_mesh and offset vector size doesn't match.");
		get_tree().quit(-1);
		return ;
	# offset the mesh at start so we the puzzle don't start already solved.
	for i in list_mesh.size():
		target_rotation.append(list_mesh[i].rotation);
		list_mesh[i].rotation_degrees.x = wrapf(list_mesh[i].rotation_degrees.x + start_angle_addition[i].x, 0.0, 360.0);
		list_mesh[i].rotation_degrees.y = wrapf(list_mesh[i].rotation_degrees.y + start_angle_addition[i].y, 0.0, 360.0);
		list_mesh[i].rotation_degrees.z = wrapf(list_mesh[i].rotation_degrees.z + start_angle_addition[i].z, 0.0, 360.0);

func	_process(delta: float) -> void:
	if solved and Time.get_ticks_msec() - solved_timestamps > 1000:
		for i in list_mesh.size():
			list_mesh[i].rotation.x = lerp_angle(list_mesh[i].rotation.x, target_rotation[i].x, delta * 0.5);
			list_mesh[i].rotation.y = lerp_angle(list_mesh[i].rotation.y, target_rotation[i].y, delta * 0.5);
			list_mesh[i].rotation.z = lerp_angle(list_mesh[i].rotation.z, target_rotation[i].z, delta * 0.5);
		if list_mesh.size() > 1:
			list_mesh[1].global_position = list_mesh[1].global_position.lerp(position_checker.global_position, delta * 0.5);
	
		if Time.get_ticks_msec() - solved_timestamps > 24000:
			set_process(false);
