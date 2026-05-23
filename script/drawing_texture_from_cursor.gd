extends Node



@export var cursor_center_anchor:Vector3
@export var cursor_radius_anchor:Vector3
@export var cursor_info:SphereCursorPositionInfo
@export var target_quad_relocation : QuadPaintRelocationInfoOfGivenCursor


func _process(delta):
	target_quad_relocation.get_cursor_info(cursor_center_anchor, cursor_radius_anchor.distance_to(cursor_center_anchor), cursor_info)
