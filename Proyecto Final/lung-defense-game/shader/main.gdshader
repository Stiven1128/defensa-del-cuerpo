shader_type canvas_item;

uniform float pulse_speed : hint_range(0.1, 3.0) = 0.8;
uniform float pulse_strength : hint_range(0.0, 0.3) = 0.08;
uniform float glow_strength : hint_range(0.0, 2.0) = 0.4;
uniform vec4 glow_color : source_color = vec4(1.0, 0.2, 0.3, 1.0);
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.6;

void fragment() {
	// Pulso como latido del corazón
	float pulse = sin(TIME * pulse_speed * 3.14159) * pulse_strength;
	vec2 uv_pulsed = UV + (UV - vec2(0.5)) * pulse;
	uv_pulsed = clamp(uv_pulsed, vec2(0.0), vec2(1.0));

	vec4 tex = texture(TEXTURE, uv_pulsed);

	// Brillo rojizo pulsante
	float glow = (sin(TIME * pulse_speed * 3.14159) * 0.5 + 0.5) * glow_strength;
	tex.rgb += glow_color.rgb * glow * tex.a;

	// Viñeta oscura en los bordes
	vec2 center = UV - vec2(0.5);
	float vignette = 1.0 - dot(center, center) * vignette_strength * 2.0;
	vignette = clamp(vignette, 0.0, 1.0);
	tex.rgb *= vignette;

	COLOR = tex;
}
