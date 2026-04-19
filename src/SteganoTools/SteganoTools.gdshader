shader_type canvas_item;


uniform vec2 screen_position;
uniform vec2 screen_size;

vec2 crt_curve(vec2 uv, float k) {
    vec2 p = uv * 2.0 - 1.0;
    float r2 = dot(p, p);
    vec2 warped = p * (1.0 + k * r2);
    return warped * 0.5 + 0.5;
}

void fragment() {
	vec2 pos = UV;
	pos = (pos - screen_position) / screen_size;
	// changement de variable, repère de l'écran,
	// avec screen pos = 0 et size = 1

	pos = crt_curve(pos, 0.065);
	if (all(lessThan(pos, vec2(1.))) && all(greaterThan(pos, vec2(0.)))) {
	    COLOR.a = 0.0;
	}
}
