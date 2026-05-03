shader_type canvas_item;

uniform float pulse_speed : hint_range(0.5, 5.0) = 3.0;
uniform float pulse_strength : hint_range(0.0, 2.0) = 0.8;
uniform vec4 evil_color : source_color = vec4(1.0, 0.1, 0.1, 1.0);
uniform float outline_width : hint_range(0.0, 5.0) = 1.5;
uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float distort_strength : hint_range(0.0, 0.05) = 0.015;

void fragment() {
	// Distorsión ondulante
	vec2 uv = UV;
	uv.x += sin(uv.y * 20.0 + TIME * pulse_speed) * distort_strength;
	uv.y += cos(uv.x * 20.0 + TIME * pulse_speed) * distort_strength;
	uv = clamp(uv, vec2(0.0), vec2(1.0));

	vec4 tex = texture(TEXTURE, uv);

	// Brillo rojo pulsante maligno
	float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
	vec3 evil_glow = evil_color.rgb * pulse * pulse_strength * tex.a;
	tex.rgb += evil_glow;

	// Outline rojo
	float outline = 0.0;
	vec2 size = TEXTURE_PIXEL_SIZE * outline_width;
	outline += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
	outline += texture(TEXTURE, UV - vec2(size.x, 0.0)).a;
	outline += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
	outline += texture(TEXTURE, UV - vec2(0.0, size.y)).a;
	outline = min(outline, 1.0);
	outline *= (1.0 - tex.a);

	COLOR = tex + vec4(outline_color.rgb, 1.0) * outline;
}