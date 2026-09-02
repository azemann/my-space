shader_type canvas_item;

uniform float charge_ratio : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	// Chambre de pression dans le sprite 144 x 64 : cellules x=39..108, y=18..38.
	vec2 chamber_min = vec2(0.27, 0.28);
	vec2 chamber_max = vec2(0.76, 0.60);
	bool in_chamber = UV.x >= chamber_min.x && UV.x <= chamber_max.x
		&& UV.y >= chamber_min.y && UV.y <= chamber_max.y;
	if (in_chamber && color.a > 0.0) {
		float local_x = (UV.x - chamber_min.x) / (chamber_max.x - chamber_min.x);
		float cells = 12.0;
		float visible_charge = floor(charge_ratio * cells + 0.001) / cells;
		if (local_x > visible_charge) {
			float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));
			color.rgb = mix(vec3(luminance), color.rgb, 0.12) * 0.22;
		} else {
			color.rgb *= 1.0 + 0.18 * charge_ratio;
		}
	}
	COLOR = color;
}
