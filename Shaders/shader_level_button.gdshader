shader_type		spatial;
//render_mode		unshaded;

uniform vec3		button_color: source_color = vec3(1.0);
uniform sampler2D	tex;
uniform int			selected = 0;

void fragment() {
	ALBEDO = texture(tex, UV).rgb;
	EMISSION = vec3(float(selected));
}