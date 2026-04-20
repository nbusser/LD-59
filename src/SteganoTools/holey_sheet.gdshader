shader_type canvas_item;

uniform sampler2D mask_texture : hint_default_white;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec4 mask = texture(mask_texture, UV);
    tex.a *= 1.0 - mask.a;
    COLOR = tex;
}