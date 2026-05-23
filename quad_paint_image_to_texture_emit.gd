class_name QuadPaintImageToTextureEmit
extends Node

@export var material: ShaderMaterial
@export var paint_color: Color = Color.GREEN
@export var cursor_resource: SphereCursorPositionInfo

func _process(delta: float) -> void:
	if material and cursor_resource:
		draw_circle(cursor_resource, paint_color)

func draw_circle(cursor: SphereCursorPositionInfo, color: Color):
	var percent_2d = Vector2(cursor.percent_width_lrtd.x, cursor.percent_width_lrtd.z)
	
	material.set_shader_parameter("center", percent_2d)
	material.set_shader_parameter("radius", cursor.radius_distance_as_width_percent)
	material.set_shader_parameter("color", color)
