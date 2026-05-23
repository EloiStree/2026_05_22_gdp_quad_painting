# SubViewportCircle.gd
class_name SubViewportCircle
extends Node

signal texture_changed(viewport_texture: ViewportTexture)

@export var viewport_size: Vector2i = Vector2i(400, 400)
@export var circle_radius: float = 120.0
@export var circle_color: Color = Color.GREEN
@export var background_color: Color = Color(0.1, 0.1, 0.1)
@export var edge_softness: float = 0.015

@export var debug_material: StandardMaterial3D
@export var shader: Shader  # Assign your circle_brush.gdshader here

var sub_viewport: SubViewport
var viewport_texture: ViewportTexture
var shader_material: ShaderMaterial
var background_rect: ColorRect
var color_rect: ColorRect


func _ready() -> void:
	create_subviewport()
	create_background()
	create_shader_rect()
	connect_texture_signal()
	apply_debug_material()
	update_shader_uniforms()  # Force initial draw


func create_subviewport() -> void:
	sub_viewport = SubViewport.new()
	sub_viewport.size = viewport_size
	sub_viewport.transparent_bg = false
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sub_viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
	add_child(sub_viewport)


func create_background() -> void:
	background_rect = ColorRect.new()
	background_rect.size = Vector2(viewport_size)
	background_rect.color = background_color
	sub_viewport.add_child(background_rect)


func create_shader_rect() -> void:
	color_rect = ColorRect.new()
	color_rect.size = Vector2(viewport_size)
	color_rect.color = Color(0, 0, 0, 0)  # Transparent so shader can blend
	
	shader_material = ShaderMaterial.new()
	if shader:
		shader_material.shader = shader
	else:
		push_error("Shader not assigned in SubViewportCircle!")
	
	color_rect.material = shader_material
	sub_viewport.add_child(color_rect)


func update_shader_uniforms() -> void:
	if not shader_material or not shader:
		return
	
	var center_uv = Vector2(0.5, 0.5)
	shader_material.set_shader_parameter("brush_center", center_uv)
	shader_material.set_shader_parameter("brush_radius", circle_radius / float(viewport_size.x))
	shader_material.set_shader_parameter("brush_color", circle_color)
	shader_material.set_shader_parameter("edge_softness", edge_softness)
	color_rect.queue_redraw()


func connect_texture_signal() -> void:
	viewport_texture = sub_viewport.get_texture()
	if viewport_texture:
		viewport_texture.changed.connect(_on_viewport_texture_changed)


func _on_viewport_texture_changed() -> void:
	texture_changed.emit(viewport_texture)
	apply_debug_material()


func apply_debug_material() -> void:
	if debug_material and viewport_texture:
		debug_material.albedo_texture = viewport_texture
		debug_material.albedo_color = Color.WHITE


func _set(property: StringName, value) -> bool:
	match property:
		"circle_radius", "circle_color", "edge_softness", "background_color":
			if background_rect:
				background_rect.color = background_color
			update_shader_uniforms()
			return true
	return false

func draw_circle_from_cursor_and_color_inspector(cursor: SphereCursorPositionInfo):
	var percent_2d = Vector2(cursor.percent_width_lrtd.x, cursor.percent_width_lrtd.z)
	var x = percent_2d.x * viewport_size.x
	var y = percent_2d.y * viewport_size.y
	var radius = cursor.radius_distance_as_width_percent * viewport_size.x 
	if not shader_material or not shader:
		return
	
	var center_uv = Vector2(x / viewport_size.x, y / viewport_size.y)
	shader_material.set_shader_parameter("brush_center", center_uv)
	shader_material.set_shader_parameter("brush_radius", radius / float(viewport_size.x))
	shader_material.set_shader_parameter("brush_color", circle_color)
	shader_material.set_shader_parameter("edge_softness", edge_softness)
	color_rect.color = Color.WHITE
	color_rect.queue_redraw()
