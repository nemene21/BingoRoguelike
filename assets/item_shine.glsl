
#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position) {
    return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
uniform float time;

vec4 lerp(vec4 col1, vec4 col2, float c) {
    return col1 + (col2 - col1) * c;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords) * color;
    return lerp(pixel, vec4(1, 1, 1, pixel.a), abs(sin(time)));
}
#endif
