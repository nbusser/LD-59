shader_type canvas_item;

uniform sampler2D texture_sampler;

uniform vec2 resolution = vec2(256, 256);

uniform float shuffle_rows_strength : hint_range(0.0, 1.0) = 0.0;
uniform float v_desync_strength : hint_range(-1.0, 1.0) = 0.0;

uniform bool enable_filter;
uniform sampler2D stegano_texture_sampler_green;
uniform vec2 filter_green_position;
uniform vec2 filter_green_size;
uniform sampler2D stegano_texture_sampler_red;
uniform vec2 filter_red_position;
uniform vec2 filter_red_size;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec2 sample_resolution(vec2 pos, vec2 res) {
    return floor(pos * res) / res;
}

float deadzone(float val, float threshold, float max_) {
    return sign(val) * smoothstep(threshold, max_, val) * max_;
}

vec2 crt_curve_inverse(vec2 uv, float k) {
    vec2 p = uv * 2.0 - 1.0;

    float rd = length(p);              // r_dst
    if (rd < 1e-6 || abs(k) < 1e-6) return uv; // guard degenerate

    // Depressed cubic: k·t³ + t - rd = 0  =>  t³ + (1/k)·t - (rd/k) = 0
    // Cardano: t³ + pt + q = 0
    float inv_k = 1.0 / k;
    float cp    =  inv_k;              // p coefficient
    float cq    = -rd * inv_k;        // q coefficient

    float disc  = 0.25 * cq * cq + (cp * cp * cp) / 27.0;
    float sq    = sqrt(max(disc, 0.0));

    float u3    = -0.5 * cq + sq;
    float v3    = -0.5 * cq - sq;

    float rs    = sign(u3) * pow(abs(u3), 1.0 / 3.0)
                + sign(v3) * pow(abs(v3), 1.0 / 3.0); // r_src

    // Reconstruct direction, scale back
    vec2 result = p * (rs / rd);
    return result * 0.5 + 0.5;
}

bool is_in_filter(vec2 raw_coords, vec2 filter_position, vec2 filter_size) {
    vec2 coord = crt_curve_inverse(raw_coords, .065);

	return coord.x >= filter_position.x &&
	coord.y >= filter_position.y &&
	coord.x <= filter_position.x + filter_size.x &&
	coord.y <= filter_position.y + filter_size.y;
}

const float v_desync_factor = 7.0;
void fragment() {
    vec2 p = resolution * shuffle_rows_strength * 2.0;

    vec2 coords = UV;
    vec2 og_coords = coords;

    coords.y += TIME * deadzone(v_desync_strength * v_desync_factor, .25, v_desync_factor);
    coords.y = mod(coords.y, 1.0);

    vec2 sampled = sample_resolution(coords, resolution);

    float random_row_factor = random(vec2(sampled.y, 12.));
    if (random_row_factor < abs(shuffle_rows_strength)) {
        // coords = vec2(random(sampled + TIME), random(sampled.yx + TIME));
        // coords = vec2(coords.x, random(sampled.yx + TIME));
        coords = vec2(coords.x, 1.-coords.y);
    }

    vec3 col = texture(texture_sampler, coords).rgb;

    if (random_row_factor < abs(shuffle_rows_strength)) {
        float rand = random(vec2(sampled.y, 5.));
        if (rand < .2) {    col = col.rbg; }
        else if (rand < .4) {    col = col.grb; }
        else if (rand < .6) {    col = col.gbr; }
        else if (rand < .8) {    col = col.brg; }
        else {    col = col.bgr; }
    }

	if (enable_filter) {
		bool is_in_green_filter = is_in_filter(og_coords, filter_green_position, filter_green_size);
		bool is_in_red_filter = is_in_filter(og_coords, filter_red_position, filter_red_size);
		if (is_in_green_filter && is_in_red_filter) {
			col = vec3(0.0, 0.0, 0.0);
		} else if (is_in_green_filter) {
			col = texture(stegano_texture_sampler_green, coords).rgb;
		} else if (is_in_red_filter) {
			col = texture(stegano_texture_sampler_red, coords).rgb;
		}
	}

    COLOR = vec4(col, 1.);
}
