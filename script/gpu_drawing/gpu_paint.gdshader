shader_type canvas_item;

uniform sampler2D current_canvas;

uniform vec2 brush_center = vec2(0.5);
uniform float brush_radius = 0.3;
uniform vec4 brush_color : source_color = vec4(1.0);
uniform float edge_softness = 0.015;

void fragment() {

	vec4 prev = texture(current_canvas, UV);

	float dist = length(UV - brush_center);

	float circle = 1.0 - smoothstep(
		brush_radius - edge_softness,
		brush_radius + edge_softness,
		dist
	);

	vec3 result = mix(prev.rgb, brush_color.rgb, circle * brush_color.a);

	COLOR = vec4(result, 1.0);
}