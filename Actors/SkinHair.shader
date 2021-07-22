shader_type canvas_item;

uniform vec4 skin_mask_color: hint_color = vec4(1.0, 0.0, 1.0, 1.0);
uniform vec4 skin_color: hint_color = vec4(1.0);
uniform vec4 hair_mask_color: hint_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 hair_color: hint_color = vec4(1.0);
uniform float tolerance: hint_range(0.0, 1.0) = .001;

void fragment() {
	vec4 color_a = texture(TEXTURE, UV);
	vec3 color = color_a.rgb;
	float a = color_a.a;
	
	float skin_mask_len = length(skin_mask_color.rgb);
	float hair_mask_len = length(hair_mask_color.rgb);
	float c_len = length(color);
	
	vec3 skin_mask_norm = skin_mask_color.rgb / skin_mask_len * c_len;
	vec3 skin_color_norm = skin_color.rgb / skin_mask_len * c_len;
	vec3 hair_mask_norm = hair_mask_color.rgb / hair_mask_len * c_len;
	vec3 hair_color_norm = hair_color.rgb / hair_mask_len * c_len;
	
	float skin_dist = distance(color, skin_mask_norm);
	float hair_dist = distance(color, hair_mask_norm);
	
	color = mix(skin_color_norm, color, step(tolerance, skin_dist));
	color = mix(hair_color_norm, color, step(tolerance, hair_dist));
	
	COLOR = vec4(color, a);
}