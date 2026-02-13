shader_type canvas_item;

uniform vec4 bubble_color : source_color = vec4(1.0);

uniform float pulse_speed = 2.0;
uniform float base_alpha = 0.1;
uniform float pulse_alpha = 0.15;
uniform float edge_softness = 0.08;
uniform float glow_strength = 0.12;

void fragment() {
	vec2 uv = UV;
	
	float edge = min(
		min(uv.x, 1.0 - uv.x),
		min(uv.y, 1.0 - uv.y)
	);
	
	float mask = smoothstep(0.0, edge_softness, edge);
	float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
	float alpha = (base_alpha + pulse * pulse_alpha) * mask;
	
	float glow = smoothstep(edge_softness, 0.0, edge);
	alpha += glow * glow_strength;
	
	alpha = clamp(alpha, 0.0, 0.35);
	
	COLOR = vec4(bubble_color.rgb, alpha);
}