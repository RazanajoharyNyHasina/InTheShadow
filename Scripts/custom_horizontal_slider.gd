extends HBoxContainer
class_name CustomHorizontalSlider

@export var label: String = "CustomHSlider";
@export var default_value: float = 0.0;
@export var min_value: float = 0.0;
@export var max_value: float = 1.0;
@export var step: float = 0.025;

@onready var label_node: Label = $Label;
@onready var h_slider_node: HSlider = $HSlider;

signal on_slider_value_changed(value: float);

func	_ready() -> void:
	label_node.text = label;
	h_slider_node.value = default_value;
	h_slider_node.min_value = min_value;
	h_slider_node.max_value = max_value;
	h_slider_node.step = step;

func	_on_mouse_entered() -> void:
	h_slider_node.grab_focus();

func	_on_h_slider_mouse_entered() -> void:
	h_slider_node.grab_focus();

func _on_h_slider_value_changed(value: float) -> void:
	on_slider_value_changed.emit(h_slider_node.value);
