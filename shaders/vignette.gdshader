shader_type canvas_item;

uniform float vignette_radius : hint_range(0.0, 1.0) = 0.55;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.4;
uniform float blur_strength : hint_range(0.0, 6.0) = 2.0;
uniform float white_amount : hint_range(0.0, 1.0) = 0.85;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

float vignette(vec2 uv, vec2 pixel_size) {
	vec2 d = uv - 0.5;
	// correct for screen aspect so the vignette is circular, not oval
	float aspect = pixel_size.y / pixel_size.x;
	d.x *= aspect;
	float dist = length(d);
	return smoothstep(vignette_radius - vignette_softness, vignette_radius, dist);
}

void fragment() {
	float v = vignette(UV, SCREEN_PIXEL_SIZE);

	// 3x3 box blur — offset scales so blur is stronger at edges
	vec2 px = SCREEN_PIXEL_SIZE * blur_strength * v;

	vec3 blurred = texture(screen_texture, SCREEN_UV).rgb;
	blurred += texture(screen_texture, SCREEN_UV + vec2( px.x,    0.0)).rgb;
	blurred += texture(screen_texture, SCREEN_UV + vec2(-px.x,    0.0)).rgb;
	blurred += texture(screen_texture, SCREEN_UV + vec2(  0.0,  px.y)).rgb;
	blurred += texture(screen_texture, SCREEN_UV + vec2(  0.0, -px.y)).rgb;
	blurred += texture(screen_texture, SCREEN_UV + vec2( px.x,  px.y)).rgb;
	blurred += texture(screen_texture, SCREEN_UV + vec2(-px.x,  px.y)).rgb;
	blurred += texture(screen_texture, SCREEN_UV + vec2( px.x, -px.y)).rgb;
	blurred += texture(screen_texture, SCREEN_UV + vec2(-px.x, -px.y)).rgb;
	blurred /= 9.0;

	vec3 sharp = texture(screen_texture, SCREEN_UV).rgb;

	// blend: sharp center → blurred edges → white edges
	vec3 color = mix(sharp, blurred, v);
	color = mix(color, vec3(1.0), v * v * white_amount);

	COLOR = vec4(color, 1.0);
}
