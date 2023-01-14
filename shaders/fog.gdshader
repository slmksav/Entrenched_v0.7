shader_type canvas_item;
render_mode unshaded;

uniform bool active = true;
uniform vec4 color: hint_color = vec4(0.194, 0.200, 0.209, 1.0);
uniform int OCTAVES = 4;
uniform float velocity = 0.25;
uniform float mul = 20.0;
uniform float smooth_pixels = 200.0;


float rand(vec2 coord) {
	// 56, 70
	return fract(sin(dot(coord, vec2(57, 70)) * 1000.0) * 1000.0);
}

float noise(vec2 coord) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));
	
	vec2 cubic = (f * f) * (3.0 - 2.0 * f);
	
	return mix(a, b, f.x) + (c - a) * f.y * (1.0 - f.x) + (d - b) * (cubic.x * cubic.y);
}

float fbm(vec2 coord) {
	float value = 0.0;
	float scale = 0.5;
	
	for (int i = 0; i < OCTAVES; i++) {
		value += noise(coord) * scale;
		coord += 2.0;
		scale *= 0.2;
	}
	
	return value;
}


void fragment() {
	if (!active) return;
	
	vec2 coord = UV * mul;
	vec2 motion = vec2(fbm(coord + (TIME * velocity)));
	float final = fbm(coord + motion);
	COLOR = vec4(color.rgb, final + 0.5);
	COLOR.a *= smoothstep(0, SCREEN_PIXEL_SIZE.x * smooth_pixels, UV.x) - smoothstep(1.0 - SCREEN_PIXEL_SIZE.x * smooth_pixels, 1.0, UV.x);
	COLOR.a *= smoothstep(0, SCREEN_PIXEL_SIZE.y * smooth_pixels, UV.y) - smoothstep(1.0 - SCREEN_PIXEL_SIZE.y * smooth_pixels, 1.0, UV.y);
}







