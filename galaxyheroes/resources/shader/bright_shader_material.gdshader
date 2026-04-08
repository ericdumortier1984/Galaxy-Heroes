shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float intensity : hint_range(3.0, 5.0, 0.1);
uniform float speed : hint_range(0.0, 10.0, 0.1);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float pulse = sin(TIME * speed) * 0.5 + 0.5;
	pulse = mix(0.3, 1.0, pulse);
	vec3 glow = glow_color.rgb * intensity * pulse;
	COLOR.rgb = glow;
	COLOR.a = tex.a;
}

