shader_type canvas_item;

void fragment() {
    // sample the original texture
	vec4 tex = texture(TEXTURE, UV);
    // compute luminance (perceptual gray) from RGB
	float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    // output gray level with the original alpha
	COLOR = vec4(vec3(gray), tex.a);
}