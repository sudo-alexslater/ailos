shader_type canvas_item;

uniform float blur_amount = 2.0;

void fragment() {
	COLOR.rgb = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount).rgb;
}