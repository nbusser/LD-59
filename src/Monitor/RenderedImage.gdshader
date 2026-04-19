shader_type canvas_item;

uniform sampler2D texture_sampler;
uniform vec2 resolution = vec2(256, 256);

uniform float shuffle_rows_strength : hint_range(0.0, 1.0) = 0.0;
uniform float v_desync_strength : hint_range(-1.0, 1.0) = 0.0;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec2 sample_resolution(vec2 pos, vec2 res) {
    return floor(pos * res) / res;
}

float deadzone(float val, float threshold, float max_) {
    return sign(val) * smoothstep(threshold, max_, val) * max_;
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

    COLOR = vec4(col, 1.);
}
