class_name QuadPaintNodeToColorPixel
extends Node

signal on_color_updated(color:Color)

@export var node_point_anchor:Node3D
@export var node_radius_anchor:Node3D
@export var gpu_brush_painter: QuadPaintGpuBrushPainter
@export var quad_relocation: QuadPaintRelocationInfoOfGivenCursor

@export var color_found: Color
@export var pixel_xy: Vector2i
@export var point_info: SphereCursorPositionInfo


func _ready() -> void:
	if point_info == null:
		point_info = SphereCursorPositionInfo.new()

func _process(delta: float) -> void:
	
	#if point_info == null:
		#point_info = SphereCursorPositionInfo.new()

	var node_point :Vector3 = node_point_anchor.global_transform.origin
	var radius_point :Vector3 = node_radius_anchor.global_transform.origin
	var radius = node_point.distance_to(radius_point)
	quad_relocation.get_cursor_info_in_resource(node_point, radius, point_info)

	var  pct_lrtd: Vector3= point_info.percent_width_lrtd
	var  pct_v2: Vector2 = Vector2(pct_lrtd.x,pct_lrtd.z)

	
	var pixel_index = gpu_brush_painter.get_pixel_index_from_percent_lrtd(pct_v2)
	color_found= gpu_brush_painter.get_color_of_last_saved_of_percent_lrtd(pct_v2)
	on_color_updated.emit(color_found)
	
