shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

const int MAX_SEGMENTS = 128;
const int MAX_POINTS = 256;

uniform vec3 points[MAX_POINTS];
uniform vec3 colors[MAX_SEGMENTS];
uniform float widths[MAX_SEGMENTS];

uniform sampler2D input_texture;

uniform int n_segments;

vec3 blend_with_alpha(vec4 col, vec3 bg) {
	return col.rgb * col.a + bg * (1.0 - col.a);
}
void fragment() {
	vec4 finalColor = vec4(0.0);
	float totalWeight = 0.0;

	// for (int i = 0; i < n_segments * 2; i += 2) {
	for (int i = 0; i < 4 * 2; i += 2) {
		vec2 a = points[i].xy;
		vec2 b = points[i+1].xy;
		vec2 p = UV;
		vec2 pa = p - a;
		vec2 ba = b - a;
		float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
		float dist = length(pa - ba * h);

		float WIDTH = widths[i/2];
		if (dist < WIDTH) {
			vec3 segmentColor = colors[i/2]; // si i / 2 a dépassé du tableau, boum
			float weight = 1.0 - dist / WIDTH;
			// finalColor.rgb += segmentColor * weight;
			finalColor.rgb += segmentColor * weight;
			// finalColor.rgb += vec3(1.0, 0.0, 0.0) * weight;
			finalColor.a = 1.0;
			totalWeight += weight;
		}
	}
	vec4 textureColor = texture(input_texture, UV);
	// if (textureColor.a == 0.0) {
		// textureColor = vec4(1.0, 1.0, 1.0, 1.0);
	// }
	finalColor = mix(textureColor, finalColor, totalWeight);
	// finalColor = mix(textureColor, finalColor, totalWeight);
	// COLOR = finalColor / totalWeight;
	COLOR = finalColor;
	// if (totalWeight > 0.0) {
	// 	COLOR = finalColor / totalWeight;
	// 	COLOR.a = 1.0;
	// } else {
	// 	COLOR.a = 0.0;
	// }
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
