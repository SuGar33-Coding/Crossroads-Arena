shader_type canvas_item;

const float PI = 3.14159265358979323846;

uniform bool active = false;
uniform float time = 0.0;
uniform float frequency = 1.0;
uniform sampler2D sheen_texure;

void vertex() {
	//VERTEX += vec2(cos(TIME)*2.0, sin(TIME)*2.0);
}

void fragment() {
	vec2 uv_offset = vec2(0.0);

	if (active) {
		uv_offset = vec2(mod(time * frequency, 1.0) * 2.0 - 1.0);
		COLOR.rgb = texture(TEXTURE, UV).rgb * pow((texture(sheen_texure, UV + uv_offset) + 1.0).rgb, vec3(4.0));
		COLOR.a = texture(TEXTURE, UV).a;
	} else {
		COLOR = texture(TEXTURE, UV);
	}

	//COLOR = texture(sheen_texure, UV + uv_offset);
	//COLOR = texture(TEXTURE, UV + uv_offset);
}