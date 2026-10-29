extends Node3D

func	_process(delta: float) -> void:
	#rotation_degrees.z = wrapf(rotation_degrees.z + (delta * 7.0), 0.0, 360.0);
	rotation_degrees.z = wrapf(rotation_degrees.z + (delta * 7.0), 0.0, 360.0);
