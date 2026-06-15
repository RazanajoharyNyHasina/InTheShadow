shader_type	spatial;

uniform sampler2D	wind_noise;
uniform sampler2D	albedo_tex;
uniform sampler2D	normal_tex;
uniform sampler2D	orm_tex;

void vertex() {
	VERTEX.xy -= texture(wind_noise, UV + (TIME * 0.2)).r * COLOR.r;
}

void fragment() {
	vec3	packed_ORM = texture(orm_tex, UV).rgb;

	ALBEDO = texture(albedo_tex, UV).rgb * packed_ORM.r;
	ROUGHNESS = packed_ORM.g;
	NORMAL = texture(normal_tex, UV).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
