extends HBoxContainer
class_name CustomOptionButton

@export var label: String = "Options Button";
@export var options_list: Array[String] = [];
@export var default_id: int: get = _get_default_id, set = _set_default_id;

func _get_default_id() -> int:
	return default_id;

func _set_default_id(id: int) -> void:
	var valid: int = clampi(id, 0, options_list.size() - 1);
	default_id = valid;
	if is_inside_tree():
		option_button_node.select(valid);

@onready var label_node: Label = $Label;
@onready var option_button_node: OptionButton = $OptionButton;
@export var grab_focus_on_ready: bool = false;

signal on_item_selected(id: int);

func	_ready() -> void:
	if grab_focus_on_ready:
		option_button_node.grab_focus();

	label_node.text = label;

	# populate options
	for i: int in options_list.size():
		option_button_node.add_item(options_list[i], i);
	option_button_node.select(clampi(default_id, 0, options_list.size() - 1));

func _on_option_button_item_selected(index: int) -> void:
	on_item_selected.emit(index);

func _on_mouse_entered() -> void:
	option_button_node.grab_focus();

func _on_option_button_mouse_entered() -> void:
	option_button_node.grab_focus();
