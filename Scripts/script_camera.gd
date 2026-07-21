extends Camera3D

@onready var camera_target: Marker3D = $"../CameraTarget";

var timestamps: int;

func	_ready() -> void:
	look_at(camera_target.global_position);
	timestamps = Time.get_ticks_msec();

func	_process(_delta: float) -> void:
	look_at(camera_target.global_position);
	if (Time.get_ticks_msec() - timestamps > 1000):
		print("PROCESS CAMERA CALLED");
		timestamps = Time.get_ticks_msec();
