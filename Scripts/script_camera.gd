extends Camera3D

@onready var camera_target: Marker3D = $"../CameraTarget";

func	_ready() -> void:
	look_at(camera_target.global_position);

func	_process(_delta: float) -> void:
	look_at(camera_target.global_position);
