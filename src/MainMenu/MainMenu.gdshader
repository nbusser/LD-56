shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

float pseudoRandom(float x) {
	return max(0., sin(x) * cos(2.*x) + 0.1 * sin(5.*x) + .5*sin(2.8*x) - .8) * .15;
}

void fragment() {
	vec4 orig_color = texture(screen_texture, SCREEN_UV);
	float x = TIME * 2.;
	COLOR.rgb = orig_color.rgb * (vec3(1.) + vec3(
		pseudoRandom(x - 0.1),
		pseudoRandom(x + 0.1),
		pseudoRandom(x + 0.05)
	));
}
