	shader_type canvas_item;
	
	uniform vec4 shield_color : source_color = vec4(1.0);
	uniform float shine_angle : hint_range(0.0, 180.0, 0.1) = 45.0;
	uniform float shine_speed : hint_range(0.01, 10.0, 0.01) = 0.3;
	uniform float shine_delay : hint_range(0.0, 5.0, 0.1) = 0.0;
	uniform bool shine_reverse = false;
	
	uniform float Line_Width : hint_range(0.0, 0.2) = 0.02;
	uniform float Line_Smoothness : hint_range(0.001, 0.1) = 0.045;
	uniform float Brightness : hint_range(0.0, 10.0) = 3.0;
	uniform float Distortion : hint_range(1.0, 3.0) = 2;
	uniform float LensStrength : hint_range(0.0, 0.1) = 0.05;
	
	void fragment() {
	vec2 uv = UV;
	
	float angle_rad = radians(shine_angle);
	vec2 shine_dir = normalize(vec2(cos(angle_rad), -sin(angle_rad)));
	vec2 shine_normal = vec2(-shine_dir.y, shine_dir.x);
	
	vec2 center_uv = uv - vec2(0.5);
	float gradient_to_edge = max(abs(center_uv.x), abs(center_uv.y));
	gradient_to_edge = 1.0 - gradient_to_edge * Distortion;
	gradient_to_edge = clamp(gradient_to_edge, 0.0, 1.0);
	
	float cycle_duration = (1.0 / shine_speed) + shine_delay;
	float time_in_cycle = mod(TIME, cycle_duration);
	float shine_progress = clamp(time_in_cycle * shine_speed, 0.0, 1.0);
	if (shine_reverse)
	{
		 shine_progress = 1.0 - shine_progress;
	}
	
	float max_offset = 1.5;
	float offset = mix(-max_offset, max_offset, shine_progress);
	vec2 shine_origin = vec2(0.5) + shine_normal * offset;
	
	float distance = dot(uv - shine_origin, shine_normal);
	float half_width = Line_Width * 0.5;
	
	float shine = smoothstep(-half_width - Line_Smoothness, -half_width, distance) -
	              smoothstep(half_width, half_width + Line_Smoothness, distance);
				
	vec2 lens_offset = shine * LensStrength * shine_normal;
	vec4 base_color = texture(TEXTURE, uv + lens_offset);
	
	if (base_color.a <= 0.0) 
	{
		 discard;
	}
	
	shine *= base_color.a;
	
	float final_intensity = shine * gradient_to_edge * Brightness;
	vec3 final_color = shield_color.rgb;
	
	final_color += shield_color.rgb * final_intensity;
	
	COLOR = vec4(final_color, base_color.a);
	}