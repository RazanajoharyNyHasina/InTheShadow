extends Button
class_name MainButton

@export var grab_focus_on_ready: bool = false;

func	_ready() -> void:
	if grab_focus_on_ready:
		grab_focus();

func _on_mouse_entered() -> void:
	grab_focus();
