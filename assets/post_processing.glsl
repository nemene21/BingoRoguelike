
uniform VolumeImage color_pallete;
uniform vec3 outline_color = vec3(0, 0, 0);
uniform float pixel_height = 1.0 / 90.0;
uniform float pixel_width  = 1.0 / 160.0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords) * color;

    if (pixel.a == 0) {
        float left  = Texel(texture, texture_coords + vec2(-pixel_width, 0)).a;
        float right = Texel(texture, texture_coords + vec2( pixel_width, 0)).a;
        float up    = Texel(texture, texture_coords + vec2(0, -pixel_height)).a;
        float down  = Texel(texture, texture_coords + vec2(0,  pixel_height)).a;

        float alpha = left + right + up + down;
        if (alpha > 0) {
            return vec4(0, 0, 0, alpha);
        }
    }
    
    pixel.rgb = Texel(color_pallete, pixel.rgb).rgb;
    return pixel;
}