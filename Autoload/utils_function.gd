extends Node

func	_are_close_to_target(value: float, target: float):
	return abs(value - target) <= 0.1;

func	compute_screen_rect(selected_mesh: MeshInstance3D, camera: Camera3D) -> Rect2:
	if selected_mesh == null:
		return Rect2(0.0, 0.0, 0.0, 0.0);

	var aabb: AABB = selected_mesh.get_aabb();
	
	var min_pos: Vector2 = Vector2(INF, INF);
	var max_pos: Vector2 = Vector2(-INF, -INF);

	for i in 8:
		var local_corner: Vector3 = aabb.get_endpoint(i);
		
		var world_corner: Vector3 = selected_mesh.to_global(local_corner);
		var screen_corner: Vector2 = camera.unproject_position(world_corner);

		min_pos.x = minf(min_pos.x, screen_corner.x);
		min_pos.y = minf(min_pos.y, screen_corner.y);

		max_pos.x = maxf(max_pos.x, screen_corner.x);
		max_pos.y = maxf(max_pos.y, screen_corner.y);

	return Rect2(min_pos, max_pos - min_pos).grow(300.0);

func _project_mouse_pos_to_sphere(
	mouse_pos: Vector2,
	bounds: Rect2
) -> Vector3:
	var radius: float = minf(
		bounds.size.x,
		bounds.size.y
	) * 0.5

	var relative: Vector2 = mouse_pos - bounds.get_center()

	var p: Vector2 = relative / radius

	var length_squared: float = p.length_squared()

	if length_squared <= 1.0:
		return Vector3(
			p.x,
			-p.y,
			sqrt(1.0 - length_squared)
		)

	# Mouse is outside the virtual sphere.
	p = p.normalized()

	return Vector3(
		p.x,
		p.y,
		0.0
	)

enum TransformType {
	ROTATION,
	TRANSLATION
}

enum AuthorizedTransform {
	ROTATION,
	TRANSLATION,
	ALL
}

enum AxeConstraint {
	FREE,
	X_ONLY,
	Y_ONLY,
	Z_ONLY
}
func	_rotate_mesh_around_trackball(
	rotation_type: AxeConstraint,
	selected_mesh: MeshInstance3D,
	previous_mouse_pos: Vector2,
	current_mouse_pos: Vector2,
	selected_mesh_rect: Rect2,
	spotlight: SpotLight3D,
	camera: Camera3D
) -> void:
	var previous: Vector3 = _project_mouse_pos_to_sphere(previous_mouse_pos, selected_mesh_rect);
	var current: Vector3 = _project_mouse_pos_to_sphere(current_mouse_pos, selected_mesh_rect);
	
	var center: Vector2 = selected_mesh_rect.get_center();
	var radius: float = minf(
		selected_mesh_rect.size.x,
		selected_mesh_rect.size.y,
	) * 0.5;
	
	var distance: float = current_mouse_pos.distance_to(center) / radius;
	
	distance = clampf(distance, 0.0, 1.0);

	var strength: float = 1.0 - distance;
	strength *= strength * strength;

	var angle: float = acos(clampf(previous.dot(current), -1.0, 1.0)) * strength;
	var axis: Vector3;
	var rotation_quaternion: Quaternion;
	
	if rotation_type == AxeConstraint.FREE:
		axis = previous.cross(current);
		if axis.length_squared() < 0.000001:
			return;

		rotation_quaternion = Quaternion((camera.global_basis * axis).normalized(), angle);
		selected_mesh.quaternion = rotation_quaternion * selected_mesh.quaternion;
		return ;

	var delta: Vector2 = current_mouse_pos - previous_mouse_pos;
	var rotation_amount: float;

	if rotation_type == AxeConstraint.X_ONLY:
		axis = spotlight.global_basis.y;
		rotation_amount = delta.x * 0.005;

	elif rotation_type == AxeConstraint.Y_ONLY:
		axis = spotlight.global_basis.x;
		rotation_amount = delta.y * 0.005;

	elif rotation_type == AxeConstraint.Z_ONLY:
		axis = spotlight.global_basis.z;
		rotation_amount = delta.y * 0.005;

	rotation_quaternion = Quaternion(axis, rotation_amount);
	selected_mesh.quaternion = rotation_quaternion * selected_mesh.quaternion;

func	_translate_around_plane(
	axe_constraint: AxeConstraint,
	selected_mesh: MeshInstance3D,
	selected_mesh_plane: Plane,
	camera: Camera3D,
	obj_start_position: Vector3,
	start_drag_position: Vector3,
	mouse_pos: Vector2
):
	var current: Vector3 = selected_mesh_plane.intersects_ray(
		camera.project_ray_origin(mouse_pos),
		camera.project_ray_normal(mouse_pos),
	);
	
	if current != null:
		var delta: Vector3 = current - start_drag_position;
		
		if axe_constraint == AxeConstraint.X_ONLY:
			delta.y = 0.0;
			delta.z = 0.0;
		elif axe_constraint == AxeConstraint.Y_ONLY:
			delta.x = 0.0;
			delta.z = 0.0;
		elif axe_constraint == AxeConstraint.Z_ONLY:
			delta.x = 0.0;
			delta.y = 0.0;
		selected_mesh.global_position = (obj_start_position + delta);
		selected_mesh.position.x = clamp(
			selected_mesh.position.x,
			-0.2,
			0.2
		);
		selected_mesh.position.y = clamp(
			selected_mesh.position.y,
			-0.2,
			0.2
		);
		selected_mesh.position.z = clamp(
			selected_mesh.position.z,
			-0.2,
			0.2
		);

func	mask_iou(a: PackedByteArray, b: PackedByteArray) -> float:
	var inter: int = 0;
	var union: int = 0;
	for i in a.size():
		inter += a[i] & b[i];
		union += a[i] | b[i];
	return 1.0 if union == 0 else float(inter) / float(union);
