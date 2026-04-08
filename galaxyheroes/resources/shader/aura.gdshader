shader_type canvas_item;

uniform vec4 aura_color : source_color = vec4(0.2, 1.0, 0.8, 1.0);
uniform float aura_thickness : hint_range(0.015, 0.1, 0.1) = 0.01;
uniform float aura_intensity : hint_range(1.5, 5.0, 0.1) = 2.5;
uniform float aura_change_speed : hint_range(2.0, 10.0, 0.1) = 2.0;

void fragment() {
	float aura_alpha = texture(TEXTURE, UV).a;
	
	float aura_outline = 0.0;
	aura_outline += texture(TEXTURE, UV + vec2(aura_thickness, 0)).a;
	aura_outline += texture(TEXTURE, UV - vec2(aura_thickness, 0)).a;
	aura_outline += texture(TEXTURE, UV + vec2(0, aura_thickness)).a;
	aura_outline += texture(TEXTURE, UV - vec2(0, aura_thickness)).a;
	aura_outline = step(0.1, aura_outline) * (1.0 - aura_alpha);
	
	float aura_pulse = sin(TIME * aura_change_speed) * 0.5 + 0.5;
	aura_pulse = mix(0.6, 1.0, aura_pulse);
	
	vec3 aura_glow = aura_color.rgb * aura_intensity * aura_pulse;
	vec4 aura_base_color = texture(TEXTURE, UV);
	
	COLOR.rgb = aura_base_color.rgb + aura_glow * aura_outline;
	COLOR.a = aura_base_color.a + aura_outline;
}

