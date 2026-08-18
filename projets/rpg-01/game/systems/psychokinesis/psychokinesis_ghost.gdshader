shader_type canvas_item;
render_mode unshaded;

uniform vec4 ghost_color : source_color = vec4(0.38, 0.86, 1.0, 0.9);
uniform float opacity : hint_range(0.0, 1.0) = 0.0;
uniform float fill_strength : hint_range(0.0, 1.0) = 0.28;
uniform float outline_strength : hint_range(0.0, 1.0) = 0.9;
uniform float outer_outline_strength : hint_range(0.0, 1.0) = 0.55;


void fragment() {
	vec4 source = texture(TEXTURE, UV);
	vec2 pixel = TEXTURE_PIXEL_SIZE;
	float around = 0.0;
	around = max(around, texture(TEXTURE, UV + vec2(pixel.x, 0.0)).a);
	around = max(around, texture(TEXTURE, UV - vec2(pixel.x, 0.0)).a);
	around = max(around, texture(TEXTURE, UV + vec2(0.0, pixel.y)).a);
	around = max(around, texture(TEXTURE, UV - vec2(0.0, pixel.y)).a);
	around = max(around, texture(TEXTURE, UV + vec2(pixel.x, pixel.y)).a);
	around = max(around, texture(TEXTURE, UV + vec2(pixel.x, -pixel.y)).a);
	around = max(around, texture(TEXTURE, UV + vec2(-pixel.x, pixel.y)).a);
	around = max(around, texture(TEXTURE, UV - vec2(pixel.x, pixel.y)).a);
	float outer_around = 0.0;
	outer_around = max(outer_around, texture(TEXTURE, UV + vec2(pixel.x * 2.0, 0.0)).a);
	outer_around = max(outer_around, texture(TEXTURE, UV - vec2(pixel.x * 2.0, 0.0)).a);
	outer_around = max(outer_around, texture(TEXTURE, UV + vec2(0.0, pixel.y * 2.0)).a);
	outer_around = max(outer_around, texture(TEXTURE, UV - vec2(0.0, pixel.y * 2.0)).a);
	outer_around = max(outer_around, texture(TEXTURE, UV + pixel * 2.0).a);
	outer_around = max(outer_around, texture(TEXTURE, UV - pixel * 2.0).a);
	outer_around = max(outer_around, texture(TEXTURE, UV + vec2(pixel.x * 2.0, -pixel.y * 2.0)).a);
	outer_around = max(outer_around, texture(TEXTURE, UV + vec2(-pixel.x * 2.0, pixel.y * 2.0)).a);
	float outline = max(around - source.a, 0.0);
	float outer_outline = max(outer_around - max(source.a, around), 0.0);
	float alpha = source.a * fill_strength + outline * outline_strength + outer_outline * outer_outline_strength;
	COLOR = vec4(ghost_color.rgb, alpha * ghost_color.a * opacity);
}
