
uniform VolumeImage color_pallete;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords) * color;
    pixel.rgb = Texel(color_pallete, pixel.rgb).rgb;
    return pixel;
}