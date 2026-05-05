shader_type canvas_item;

// ── Latido ────────────────────────────────────────────
uniform float heartbeat_speed : hint_range(0.1, 3.0) = 1.2;
uniform float heartbeat_strength : hint_range(0.0, 0.05) = 0.018;

// ── Respiración ───────────────────────────────────────
uniform float breath_speed : hint_range(0.1, 2.0) = 0.4;
uniform float breath_strength : hint_range(0.0, 0.03) = 0.012;

// ── Color y brillo ────────────────────────────────────
uniform float glow_strength : hint_range(0.0, 1.0) = 0.25;
uniform vec4 blood_color : source_color = vec4(0.9, 0.1, 0.15, 1.0);
uniform float saturation_boost : hint_range(0.0, 2.0) = 1.3;
uniform float contrast_boost : hint_range(0.5, 2.0) = 1.15;

// ── Viñeta ────────────────────────────────────────────
uniform float vignette_strength : hint_range(0.0, 3.0) = 1.4;
uniform float vignette_roundness : hint_range(0.0, 2.0) = 1.2;

// ── Ruido orgánico ────────────────────────────────────
uniform float noise_strength : hint_range(0.0, 0.05) = 0.008;
uniform float noise_speed : hint_range(0.0, 3.0) = 0.6;

// ── Aberración cromática ──────────────────────────────
uniform float chromatic_strength : hint_range(0.0, 0.01) = 0.003;

// Función de ruido simple
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i), hash(i + vec2(1,0)), f.x),
		mix(hash(i + vec2(0,1)), hash(i + vec2(1,1)), f.x),
		f.y
	);
}

void fragment() {
	vec2 uv = UV;

	// ── 1. LATIDO DEL CORAZÓN ─────────────────────────
	// Simula dos pulsos rápidos seguidos de una pausa (lub-dub)
	float t = TIME * heartbeat_speed;
	float beat1 = exp(-8.0 * fract(t) * fract(t));
	float beat2 = exp(-8.0 * max(0.0, fract(t) - 0.15) * max(0.0, fract(t) - 0.15)) * 0.6;
	float heartbeat = (beat1 + beat2) * heartbeat_strength;
	// El pulso expande desde el centro
	vec2 center_offset = (uv - vec2(0.5)) * heartbeat;
	uv -= center_offset;

	// ── 2. RESPIRACIÓN LENTA ──────────────────────────
	// Movimiento suave de expansión y contracción
	float breath = sin(TIME * breath_speed * 3.14159) * breath_strength;
	uv += (uv - vec2(0.5)) * breath;

	// ── 3. RUIDO ORGÁNICO ─────────────────────────────
	// Pequeñas ondulaciones como tejido vivo
	float nx = noise(uv * 8.0 + TIME * noise_speed) * 2.0 - 1.0;
	float ny = noise(uv * 8.0 + TIME * noise_speed + 100.0) * 2.0 - 1.0;
	uv += vec2(nx, ny) * noise_strength;
	uv = clamp(uv, vec2(0.001), vec2(0.999));

	// ── 4. ABERRACIÓN CROMÁTICA ───────────────────────
	// Separa los canales RGB ligeramente para efecto orgánico
	float r = texture(TEXTURE, uv + vec2(chromatic_strength, 0.0)).r;
	float g = texture(TEXTURE, uv).g;
	float b = texture(TEXTURE, uv - vec2(chromatic_strength, 0.0)).b;
	float a = texture(TEXTURE, uv).a;
	vec4 tex = vec4(r, g, b, a);

	// ── 5. BOOST DE SATURACIÓN ────────────────────────
	float luminance = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	tex.rgb = mix(vec3(luminance), tex.rgb, saturation_boost);

	// ── 6. BOOST DE CONTRASTE ─────────────────────────
	tex.rgb = (tex.rgb - 0.5) * contrast_boost + 0.5;
	tex.rgb = clamp(tex.rgb, 0.0, 1.0);

	// ── 7. BRILLO ROJO PULSANTE (sangre) ─────────────
	float pulse_glow = (beat1 + beat2 * 0.5) * glow_strength;
	tex.rgb += blood_color.rgb * pulse_glow * tex.a;

	// ── 8. VIÑETA ORGÁNICA ────────────────────────────
	// Oscurece los bordes con forma irregular
	vec2 vig_uv = UV - vec2(0.5);
	float vig = pow(dot(vig_uv * vec2(1.0, vignette_roundness),
						vig_uv * vec2(1.0, vignette_roundness)), 0.5);
	float vignette = 1.0 - smoothstep(0.3, 0.85, vig * vignette_strength);
	tex.rgb *= vignette;

	// ── 9. TONO CÁLIDO EN EL CENTRO ──────────────────
	float center_dist = 1.0 - length(UV - vec2(0.5)) * 1.8;
	center_dist = clamp(center_dist, 0.0, 1.0);
	tex.rgb += vec3(0.08, 0.02, 0.02) * center_dist;

	COLOR = vec4(tex.rgb, a);
}