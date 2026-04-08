shader_type canvas_item;

uniform float strength = 2.0;
uniform float speed = 1.0;

void fragment() {
    vec2 uv = UV;

    float wave = sin((UV.y * 10.0) + TIME * speed) * strength;

    uv.x -= wave;

    vec4 tex = texture(TEXTURE, uv);

    COLOR = tex;
}