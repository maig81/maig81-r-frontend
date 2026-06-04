shader_type canvas_item;

uniform sampler2D noise_texture : repeat_enable;
uniform float uv_scale : hint_range(0.001, 0.02) = 0.005;
uniform float smoothstep_lo : hint_range(0.0, 1.0) = 0.1;
uniform float smoothstep_hi : hint_range(0.0, 1.0) = 0.9;
uniform float alpha_min : hint_range(0.0, 1.0) = 0.0;
uniform float alpha_max : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float n = texture(noise_texture, FRAGCOORD.xy * uv_scale).r;
	float t = smoothstep(smoothstep_lo, smoothstep_hi, n);
	COLOR.a *= mix(alpha_min, alpha_max, t);
}
