class_name QuadPaintGpuBrushPainter
extends Node

signal texture_updated(texture: Texture2D)
@export var apply_to_material:Array[StandardMaterial3D]
@export var apply_to_color_rect: Array[TextureRect]

@export var viewport_size: Vector2i = Vector2i(4096, 4096)
@export var edge_softness: float = 0.015
@export var shader: Shader

@export var brush_is_true:bool
@export var brush_color_true: Color = Color.GREEN
@export var brush_color_false:Color=Color.BLACK*0.9

var vp_a: SubViewport
var vp_b: SubViewport
var rect_a: ColorRect
var rect_b: ColorRect
var mat_a: ShaderMaterial
var mat_b: ShaderMaterial
var use_a_as_source := true

func _ready() -> void:
	_setup_viewports()
	
func _setup_viewports() -> void:
	vp_a = _create_viewport()
	vp_b = _create_viewport()
	add_child(vp_a)
	add_child(vp_b)
	rect_a = _create_layer(vp_a)
	rect_b = _create_layer(vp_b)
	mat_a = rect_a.material
	mat_b = rect_b.material

func _create_viewport() -> SubViewport:
	var vp = SubViewport.new()
	vp.size = viewport_size
	vp.transparent_bg = false
	vp.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	return vp
	
func _create_layer(parent: SubViewport) -> ColorRect:
	var rect = ColorRect.new()
	rect.size = Vector2(viewport_size)
	rect.color = Color.WHITE

	var mat = ShaderMaterial.new()
	mat.shader = shader
	rect.material = mat
	parent.add_child(rect)
	return rect
	
func paint_at(cursor_uv: Vector2, radius_uv: float, color:Color) -> void:
	var src = vp_a if use_a_as_source else vp_b
	var dst = vp_b if use_a_as_source else vp_a
	var dst_mat = mat_b if use_a_as_source else mat_a
	dst_mat.set_shader_parameter("current_canvas", src.get_texture())
	dst_mat.set_shader_parameter("brush_center", cursor_uv)
	dst_mat.set_shader_parameter("brush_radius", radius_uv)
	dst_mat.set_shader_parameter("brush_color", color)
	dst_mat.set_shader_parameter("edge_softness", edge_softness)
	dst.render_target_update_mode = SubViewport.UPDATE_ONCE
	use_a_as_source = !use_a_as_source
	var texture :=dst.get_texture()
	texture_updated.emit(texture)
	
	if apply_to_material:
		for m in apply_to_material:
			if m:
				m.albedo_texture= texture

	if apply_to_color_rect:
		for m in apply_to_color_rect:
			if m:
				m.texture = texture
		

func draw_from_resoruce(cursor: SphereCursorPositionInfo):
	if not cursor.is_touching_quad:
		return 
	var percent_2d = Vector2(cursor.percent_width_lrtd.x, cursor.percent_width_lrtd.z)
	var x = percent_2d.x * viewport_size.x
	var y = percent_2d.y * viewport_size.y
	var radius = cursor.touching_radius_as_width_percent
	var center_uv = Vector2(x / viewport_size.x, y / viewport_size.y)
	var color := brush_color_true if brush_is_true else brush_color_false
	paint_at(center_uv,radius,color)
	##brush_color = Color(randf(),randf(),randf())
	
