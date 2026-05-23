class_name QuadPaintCursorToRelocatedInfo
extends Node


signal on_cursor_info_updated(resource_ref:QuadPaintRelocationInfoOfGivenCursor)

@export var cursor_info: SphereCursorPositionInfo
@export var cursor_quad: QuadPaintRelocationInfoOfGivenCursor
@export var node_center_anchor:Node3D
@export var node_radius_anchor:Node3D
@export var position:Vector3


func _process(delta: float) -> void:
	if cursor_info and cursor_quad and node_center_anchor and node_radius_anchor:
		var center_pos = node_center_anchor.global_transform.origin
		var radius = node_radius_anchor.global_transform.origin.distance_to(center_pos)
		cursor_quad.get_cursor_info_in_resource(center_pos, radius, cursor_info)
		position = cursor_info.percent_width_lrtd
		on_cursor_info_updated.emit(cursor_info)
