extends Control

func	add_button(text: String, callable: Callable) -> Button:
	var button: Button = Button.new();
	
	button.text = text;
	button.pressed.connect(callable);
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER;
	button.grow_horizontal = Control.GROW_DIRECTION_BOTH;
	button.mouse_entered.connect(func focus(): button.grab_focus());
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND;
	return button;

func	add_options(text: String, callable: Callable, options_array: Array[String], default_start: int) -> HBoxContainer:
	var container: HBoxContainer = HBoxContainer.new();
	var options: OptionButton = OptionButton.new();
	var label: Label = Label.new();

	label.text = text;

	container.add_child(label);
	container.add_child(options);
	container.add_theme_constant_override("separation", 64);
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL;
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL;

	label.mouse_entered.connect(func label_hovered() -> void: options.grab_focus());
	label.mouse_filter = Control.MOUSE_FILTER_PASS;
	options.alignment = HORIZONTAL_ALIGNMENT_LEFT;
	options.item_selected.connect(callable);
	options.mouse_entered.connect(func options_hovered() -> void: options.grab_focus());
	for i in options_array.size():
		options.add_item(options_array[i], i);
	options.selected = default_start;
	return container;

func	add_horizontal_slider(text: String, callable: Callable, default_min_max_step: Vector4) -> HBoxContainer:
	var container: HBoxContainer = HBoxContainer.new();
	var slider: HSlider = HSlider.new();
	var label: Label = Label.new();
	
	label.text = text;
	label.mouse_filter = Control.MOUSE_FILTER_PASS;
	label.mouse_entered.connect(func label_connected(): slider.grab_focus());
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL;
	slider.size_flags_vertical = Control.SIZE_EXPAND_FILL;
	slider.min_value = default_min_max_step.y;
	slider.max_value = default_min_max_step.z;
	slider.step = default_min_max_step.w;
	slider.set_value_no_signal(default_min_max_step.x);
	slider.rounded = true;
	slider.drag_ended.connect(callable.bind(slider));
	slider.mouse_entered.connect(func slider_hovered(): slider.grab_focus());
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL;
	container.add_theme_constant_override("separation", 12);
	container.add_child(label);
	container.add_child(slider);
	
	return container;

func	add_toggle_button(text: String, callable: Callable, default_status: bool) -> CheckButton:
	var check_button: CheckButton = CheckButton.new();
	
	check_button.text = text;
	check_button.mouse_entered.connect(func check_button_hovered() -> void: check_button.grab_focus());
	check_button.toggled.connect(callable);
	check_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL;
	check_button.set_pressed_no_signal(default_status);
	return check_button;
