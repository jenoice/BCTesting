shader_type canvas_item;

uniform float scale : hint_range(0.1, 10) = 2.0;
uniform vec4 color : source_color;
uniform float flash : hint_range(0,1) = 0.5;
uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 pix = texture(TEXTURE, UV);
	COLOR = pix;
	COLOR.rgb = COLOR.ggg * 2.0;
	
}
