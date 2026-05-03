shader_type canvas_item;

uniform float glow_speed : hint_range(0.5, 5.0) = 2.0;
uniform float glow_strength : hint_range(0.0, 3.0) = 1.2;
uniform vec4 glow_color : source_color = vec4(0.4, 0.8, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 5.0) = 1.5;
uniform vec4 outline_color : source_color = vec4(0.2, 0.6, 1.0, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// Brillo pulsante azul
	float pulse = sin(TIME * glow_speed) * 0.5 + 0.5;
	vec3 glow = glow_color.rgb * pulse * glow_strength * tex.a;
	tex.rgb += glow;

	// Outline brillante
	float outline = 0.0;
	vec2 size = TEXTURE_PIXEL_SIZE * outline_width;
	outline += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
	outline += texture(TEXTURE, UV - vec2(size.x, 0.0)).a;
	outline += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
	outline += texture(TEXTURE, UV - vec2(0.0, size.y)).a;
	outline = min(outline, 1.0);
	outline *= (1.0 - tex.a);

	vec4 final_color = tex + vec4(outline_color.rgb, 1.0) * outline;
	COLOR = final_color;
}
