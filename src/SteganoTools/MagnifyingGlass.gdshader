shader_type canvas_item;

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float dist = length(uv);

	if (dist < 0.9) {
		COLOR = vec4(0.45, 0.7, 1.0, 0.08);
	} else if (dist < 1.0) {
		COLOR = vec4(0.82, 0.82, 0.82, 1.0);
	} else {
		COLOR.a = 0.0;
	}
}
