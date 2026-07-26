@tool
extends Node3D

enum ButtonStatus {
	LEVEL_LOCKED,
	LEVEL_DONE
}

@onready var box: MeshInstance3D = $Box;
@onready var level_hint: Label3D = $LevelHint;


@export var status: ButtonStatus:
	set(value):
		var target: Vector3;

		if value == ButtonStatus.LEVEL_DONE:
			target.y = 180.0;
		elif value == ButtonStatus.LEVEL_LOCKED:
			target.y = 0.0;
		create_tween().tween_property(box, "rotation_degrees", target, 0.5);
		status = value;
	get():
		return status

@export var selected: bool :
	set(value):
		var box_material = box.mesh.surface_get_material(0);

		box_material.set_shader_parameter("selected", 0 if value == false else 1);
		selected = value;
	get():
		return selected;
