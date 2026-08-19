// Anime une surface en espace mondial avec deux vagues pixelisées. Les profils
// .tres fournissent des valeurs différentes pour l'eau, l'écume, la lave, le
// poison et la magie sans dupliquer ce shader.
shader_type canvas_item;

// Vitesse de déplacement temporel des vagues.
uniform float speed : hint_range(0.0, 8.0) = 1.0;
// Force du changement de couleur appliqué à la texture d'origine.
uniform float intensity : hint_range(0.0, 0.5) = 0.08;
// Densité du motif dans l'espace mondial.
uniform float spatial_frequency : hint_range(0.001, 0.25) = 0.05;
// Cadence discrète qui préserve l'aspect d'une animation pixel art.
uniform float animation_fps : hint_range(1.0, 30.0) = 8.0;
// Axe principal suivant lequel le motif se déplace.
uniform vec2 flow_direction = vec2(1.0, 0.25);
// Couleur ajoutée aux vagues et aux reflets.
uniform vec4 tint_color : source_color = vec4(0.35, 0.82, 1.0, 1.0);
// Niveau du motif à partir duquel un reflet clair apparaît.
uniform float highlight_threshold : hint_range(0.0, 1.0) = 0.72;
// Décalage temporel optionnel pour désynchroniser deux surfaces identiques.
uniform float phase_offset = 0.0;

varying vec2 world_position;


void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}


void fragment() {
	float stepped_time = floor(TIME * animation_fps) / animation_fps;
	vec2 direction = normalize(flow_direction);
	float travel = dot(world_position, direction) * spatial_frequency;
	float cross_wave = dot(world_position, vec2(-direction.y, direction.x)) * spatial_frequency * 0.63;
	float wave_a = sin(travel - stepped_time * speed + phase_offset);
	float wave_b = sin(cross_wave + stepped_time * speed * 0.71 + phase_offset * 1.7);
	float wave = wave_a * 0.62 + wave_b * 0.38;
	float highlight = smoothstep(highlight_threshold, 1.0, wave * 0.5 + 0.5);
	vec4 base = COLOR;
	base.rgb += tint_color.rgb * (wave * 0.35 + highlight * 0.65) * intensity * base.a;
	COLOR = base;
}
