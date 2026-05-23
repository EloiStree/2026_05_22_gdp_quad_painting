class_name QuadPaintDrawFromImageTextureGpu
extends Node

@export var set_as_active: bool = true
@export var canvas_size: Vector2i = Vector2i(4096, 4096)
@export var background_color: Color = Color.WHITE
@export var drawing_color: Color = Color.GREEN

@export var texture_rect: TextureRect
@export var material: StandardMaterial3D

@export var shader: Shader

var viewport: SubViewport
var paint_rect: ColorRect
var canvas_texture: ViewportTexture
var current_canvas_image: Image  # To store the painted state

func _ready():
	# Create offscreen painting viewport
	viewport = SubViewport.new()
	viewport.size = canvas_size
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = true
	add_child(viewport)
	
	# Background
	var bg = ColorRect.new()
	bg.color = background_color
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	viewport.add_child(bg)
	
	# Create initial canvas image
	current_canvas_image = Image.create(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	current_canvas_image.fill(background_color)
	
	# Paint layer
	paint_rect = ColorRect.new()
	paint_rect.anchor_right = 1.0
	paint_rect.anchor_bottom = 1.0
	paint_rect.material = ShaderMaterial.new()
	paint_rect.material.shader = shader
	viewport.add_child(paint_rect)
	
	# Set initial canvas texture for shader
	var initial_texture = ImageTexture.create_from_image(current_canvas_image)
	(paint_rect.material as ShaderMaterial).set_shader_parameter("current_canvas", initial_texture)
	
	# Get the final texture
	canvas_texture = viewport.get_texture()
	
	if texture_rect:
		texture_rect.texture = canvas_texture
		texture_rect.custom_minimum_size = canvas_size
	
	if material:
		material.albedo_texture = canvas_texture

func draw_circle_from_cursor(cursor: SphereCursorPositionInfo):
	if not set_as_active:
		return
	
	var percent_2d = Vector2(cursor.percent_width_lrtd.x, cursor.percent_width_lrtd.z)
	var center = percent_2d  # already in UV space (0-1)
	
	var radius = cursor.radius_distance_as_width_percent * 0.5
	
	# Update shader uniforms
	var mat = paint_rect.material as ShaderMaterial
	
	# CRITICAL: Get the current painted result and update the shader
	var current_texture = get_painted_texture()
	mat.set_shader_parameter("current_canvas", current_texture)
	mat.set_shader_parameter("brush_center", center)
	mat.set_shader_parameter("brush_radius", radius)
	mat.set_shader_parameter("brush_color", drawing_color)
	
	# Force viewport update and capture result
	await RenderingServer.frame_post_draw
	paint_rect.queue_redraw()
	await RenderingServer.frame_post_draw
	
	# Store the newly painted image
	capture_current_canvas()

func get_painted_texture() -> ImageTexture:
	# Get the current state of the paint_rect as texture
	var image = viewport.get_texture().get_image()
	return ImageTexture.create_from_image(image)

func capture_current_canvas():
	# Capture and store the current canvas state
	current_canvas_image = viewport.get_texture().get_image()
	
	# Update the material texture reference
	if material:
		material.albedo_texture = canvas_texture

func clear_canvas():
	current_canvas_image.fill(background_color)
	var clear_texture = ImageTexture.create_from_image(current_canvas_image)
	(paint_rect.material as ShaderMaterial).set_shader_parameter("current_canvas", clear_texture)
	paint_rect.queue_redraw()
	await RenderingServer.frame_post_draw
	capture_current_canvas()
