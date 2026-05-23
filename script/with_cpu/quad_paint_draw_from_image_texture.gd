class_name QuadPaintDrawFromImageTexture
extends Node

@export var set_as_active:bool=true
@export var canvas_size: Vector2i = Vector2i(4096, 4096)
@export var background_color: Color = Color.WHITE

var image: Image
var texture: ImageTexture

@export var   texture_rect: TextureRect 
@export var   material: StandardMaterial3D
@export var   color: Color = Color.GREEN

func _ready():
	# Create blank canvas
	image = Image.create(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	image.fill(background_color)
	
	texture = ImageTexture.create_from_image(image)
	if texture_rect:
		texture_rect.texture = texture
		texture_rect.custom_minimum_size = canvas_size
	if material:
		material.albedo_texture = texture

# Draw a circle
func draw_circle(pos: Vector2, radius: float, color: Color):
	if not set_as_active:
		return 
	var radius_squared = radius * radius
	for x in range(-int(radius), int(radius) + 1):
		for y in range(-int(radius), int(radius) + 1):
			if x * x + y * y <= radius_squared:
				var px = int(pos.x) + x
				var py = int(pos.y) + y
				if px >= 0 and px < canvas_size.x and py >= 0 and py < canvas_size.y:
					image.set_pixel(px, py, color)
	texture.update(image)

# Draw a line (good for freehand drawing)
func draw_line(start: Vector2, end: Vector2, color: Color, width: float = 4.0):
	image.draw_line(start, end, color, width, true)
	texture.update(image)

# Clear canvas
func clear():
	image.fill(background_color)
	texture.update(image)

func draw_circle_from_cursor_and_color_inspector(cursor: SphereCursorPositionInfo):
	var percent_2d = Vector2(cursor.percent_width_lrtd.x, cursor.percent_width_lrtd.z)
	var x = percent_2d.x * canvas_size.x
	var y = percent_2d.y * canvas_size.y
	var radius = cursor.radius_distance_as_width_percent * canvas_size.x / 2
	draw_circle(Vector2(x, y), radius, color)	
