shader_type canvas_item;

void vertex()
{
// Called for every vertex the material is visible on.
}

uniform sampler2D history;
uniform sampler2D tmp;
uniform sampler2D new;

float hue_to_rgb(float p, float q, float t)
{
	if (t < 0.0)
		t += 1.0;
	if (t > 1.0)
		t -= 1.0;
	if (t < 1.0 / 6.0)
		return p + (q - p) * 6.0 * t;
	if (t < 1.0 / 2.0)
		return q;
	if (t < 2.0 / 3.0)
		return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
	return p;
}

vec3 rgb_to_hsl(vec3 color)
{
	float maxColor = max(max(color.r, color.g), color.b);
	float minColor = min(min(color.r, color.g), color.b);
	float delta = maxColor - minColor;

	float h = 0.0;
	float s = 0.0;
	float l = (maxColor + minColor) / 2.0;

	if (delta != 0.0) {
		s = l <
		    0.5 ? delta / (maxColor + minColor) : delta / (2.0 -
								   maxColor -
								   minColor);

		if (color.r == maxColor) {
			h = (color.g - color.b) / delta + (color.g <
							   color.b ? 6.0 : 0.0);
		} else if (color.g == maxColor) {
			h = (color.b - color.r) / delta + 2.0;
		} else {
			h = (color.r - color.g) / delta + 4.0;
		}
		h /= 6.0;
	}

	return vec3(h, s, l);
}

vec3 hsl_to_rgb(vec3 hsl)
{
	vec3 rgb;

	if (hsl.y == 0.0) {
		rgb = vec3(hsl.z);
	} else {
		float q =
		    hsl.z <
		    0.5 ? hsl.z * (1.0 + hsl.y) : hsl.z + hsl.y - hsl.z * hsl.y;
		float p = 2.0 * hsl.z - q;

		rgb.r = hue_to_rgb(p, q, hsl.x + 1.0 / 3.0);
		rgb.g = hue_to_rgb(p, q, hsl.x);
		rgb.b = hue_to_rgb(p, q, hsl.x - 1.0 / 3.0);
	}

	return rgb;
}

const float DARK_COEF = 1.3;
const float BORNE_INF = 0.5;
vec3 darken(vec3 color)
{
	vec3 hsl = rgb_to_hsl(color);
	hsl.yz = BORNE_INF + (hsl.yz - BORNE_INF) / DARK_COEF;
	return hsl_to_rgb(hsl);
}

void fragment()
{
	vec4 h = texture(history, UV);
	if (h.rgb == vec3(1.0))
		h.a = 0.0;
	vec4 t = texture(tmp, UV);
	if (t.rgb == vec3(1.0))
		t.a = 0.0;
	vec4 n = texture(new, UV);
	if (n.rgb == vec3(1.0))
		n.a = 0.0;

	float h_hue = rgb_to_hsl(h.rgb).x;
	float n_hue = rgb_to_hsl(n.rgb).x;

	COLOR = n;
	if (n.a == 0.0) {
		COLOR = h;
	} else if (h.a > 0. && abs(h_hue - n_hue) < 0.1 && t.a == 0.0) {
		COLOR.rgb = darken(h.rgb);
	}
	if (h.rgb == vec3(0.0))
		COLOR = vec4(1.0, 1.0, 1.0, 0.0);
}
