shader_type canvas_item;

uniform float scale : hint_range(0.1, 10) = 2.0;
uniform vec4 color : source_color;
uniform float flash : hint_range(0,1) = 0.5;
uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 distoredUV = SCREEN_UV + texture(TEXTURE, UV).r + 0.05;
	vec4 screenColor =  texture(screen_texture, distoredUV);
	COLOR = screenColor;
	
//	vec4 pix = texture(TEXTURE, UV);
//	COLOR = pix;
//	COLOR.rgb = COLOR.rbr;
	
//	vec4 pix = texture(TEXTURE, UV);
//	COLOR = mix(pix, color, flash);
//	COLOR.a *= pix.a;
	
//	vec4 pix = texture(TEXTURE, UV);
//	float brightness = (pix.r + pix.g + pix.b) / 3.0;
//	vec4 grayscale = vec4(brightness, brightness, brightness, pix.a);
//	COLOR = grayscale * color;
	
//	vec2 distortedUV = UV;
//	distortedUV.x += distortedUV.y * 0.2;
//	vec4 pix = texture(TEXTURE, distortedUV);
//	COLOR = pix;
	
}
