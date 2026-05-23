shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D current_canvas : source_color, filter_linear;
uniform vec2 brush_center = vec2(0.5);
uniform float brush_radius = 0.3;
uniform vec4 brush_color : source_color = vec4(1.0);
uniform float edge_softness = 0.015;

void fragment() {
    vec4 current = texture(current_canvas, UV);
    
    float dist = length(UV - brush_center);
    float circle = 1.0 - smoothstep(brush_radius - edge_softness, 
                                    brush_radius + edge_softness, 
                                    dist);
    
    vec3 mixed_rgb = mix(current.rgb, brush_color.rgb, circle * brush_color.a);
    COLOR = vec4(mixed_rgb, current.a);
}