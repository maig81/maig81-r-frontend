shader_type canvas_item;

uniform sampler2D noise_texture : repeat_enable;
uniform float smoothstep_lo : hint_range(0.0, 1.0) = 0.3;
uniform float smoothstep_hi : hint_range(0.0, 1.0) = 0.4;
uniform float pencil_alpha_min : hint_range(0.0, 1.0) = 0.1;
uniform float pencil_alpha_max : hint_range(0.0, 1.0) = 0.3;
uniform vec2 uv_offset = vec2(0.0, 0.0);

void fragment() {
	float n = texture(noise_texture, UV + uv_offset).r;
	float t = smoothstep(smoothstep_lo, smoothstep_hi, n);
	COLOR.a *= mix(pencil_alpha_min, pencil_alpha_max, t);
}
