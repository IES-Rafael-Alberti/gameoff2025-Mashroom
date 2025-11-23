shader_type canvas_item;
// Taken from https://godotshaders.com/shader/transition-between-two-textures/

uniform sampler2D texture_1 : source_color, repeat_enable, filter_nearest;
uniform sampler2D texture_2 : source_color, repeat_enable, filter_nearest;
uniform float transform_ratio : hint_range(0.0, 1.0, 0.01) = 1.0;

void fragment() {
	vec4 a = texture(texture_1, UV);
	vec4 b = texture(texture_2, UV);
	// blend color and alpha using transform_ratio (1.0 => show texture_1, 0.0 => show texture_2)
	vec4 blended = mix(b, a, transform_ratio);
	COLOR = blended;
}
