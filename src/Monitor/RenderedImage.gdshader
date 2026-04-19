shader_type canvas_item;

uniform float blur_strength : hint_range(0.0, 1.0) = 0.0;

// This shader is the scrambling/descrambling shaders

// Not working, just a PoC
void fragment() {
    vec2 p = TEXTURE_PIXEL_SIZE * blur_strength * 2.0;

    COLOR = (
        texture(TEXTURE, UV + vec2(-p.x, -p.y)) * 1.0 +
        texture(TEXTURE, UV + vec2( 0.0, -p.y)) * 2.0 +
        texture(TEXTURE, UV + vec2( p.x, -p.y)) * 1.0 +
        texture(TEXTURE, UV + vec2(-p.x,  0.0)) * 2.0 +
        texture(TEXTURE, UV                   ) * 4.0 +
        texture(TEXTURE, UV + vec2( p.x,  0.0)) * 2.0 +
        texture(TEXTURE, UV + vec2(-p.x,  p.y)) * 1.0 +
        texture(TEXTURE, UV + vec2( 0.0,  p.y)) * 2.0 +
        texture(TEXTURE, UV + vec2( p.x,  p.y)) * 1.0
    ) / 16.0;
}