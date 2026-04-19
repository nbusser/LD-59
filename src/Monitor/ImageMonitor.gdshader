shader_type canvas_item;

// This shader is only for cosmetic VHS style

uniform vec2 resolution = vec2(256, 256);
uniform float convol: hint_range(-1., 1.) = 0.5;
uniform sampler2D texture_sampler;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

const int K = 3;
const float float_arr[K*K] = float[K*K] (1.0, 1.0, 1.0, 1.0, -7.0, 1.0, 1.0, 1.0, 1.0);
const float float_arr_og[K*K] = float[K*K] (0.,0.,0.,0., 1.0, 0.,0.,0.,0.);

vec3 convolve(vec2 pos, float scale) {
    vec2 step_ = 1. / resolution;
    vec3 total = vec3(0.0);
    for (int i = -1; i < K - 1; i++) {
        for (int j = -1; j < K - 1; j++) {
            vec2 coords = vec2(float(i), float(j));
            coords = step_ * coords;

            coords = pos + coords;
            float modif = float_arr[(i + 1)*K + j + 1] / 1.;
            float modif_og = float_arr_og[(i + 1)*K + j + 1] / 1.;
            total += texture(texture_sampler, coords).rgb * mix(modif_og, modif, scale);
        }
    }
    // return total / float(K * K);
    return total;
}

void fragment() {
    vec2 uv = UV;
    uv = floor(uv * resolution) / resolution;
    vec2 ratio = resolution / min(resolution.x, resolution.y);

    vec2 global_coords = uv * ratio;


	vec4 final_color = vec4(0.0);
	final_color.rgb = vec3(0.0);

     COLOR.rgb = convolve(uv, convol);
}
