shader_type canvas_item;

uniform vec4 shield_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform float radius = 0.6;
uniform float edge_softness = 0.6;
uniform float base_alpha = 0.0;
uniform float glow_strength = 0.6;
uniform float stretch = 0.7;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	uv.y /= stretch;
	uv.x *= stretch + 0.01;
	float dist = length(uv);
	float circle = 1.0 - smoothstep(radius - edge_softness, radius, dist);

	float glow = smoothstep(radius, radius - edge_softness, dist);

	float alpha = circle * base_alpha;
	alpha += glow * glow_strength;

	COLOR = vec4(shield_color.rgb, alpha);
}