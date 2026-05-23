class_name SphereCursorPositionInfo
extends Resource
@export var cursor_center_anchor:Vector3
@export var radius_distance:float
@export var percent_width_lrdt:Vector3
@export var percent_width_lrtd:Vector3
@export var cursor_local_position:Vector3
@export var diameter_distance:float
@export var radius_distance_as_width_percent:float
@export var diameter_distance_as_width_percent:float
@export var touching_radius:float	
@export var touching_radius_as_width_percent:float
@export var touching_diameter:float
@export var touching_diameter_as_width_percent:float
@export var quad_width :float
@export var quad_height :float
@export var is_touching_quad:bool



func get_pixel_position_in_quad_from_lrtd(image_width:int, image_height:int) -> Vector2i:
	if not is_touching_quad:
		return Vector2i(-1, -1)
	var pixel_position = Vector2(percent_width_lrtd.x * image_width, percent_width_lrtd.y * image_height)
	return Vector2i(int(pixel_position.x), int(pixel_position.y))

func get_pixel_color_from_image(image:Image) -> Color:
	var pixel_position = get_pixel_position_in_quad_from_lrtd(image.get_width(), image.get_height())
	if pixel_position.x < 0 or pixel_position.y < 0:
		return Color(0, 0, 0, 0)
	return image.get_pixelv(pixel_position)


func get_pixels_position_in_quad_from_lrtd(image_width:int, image_height:int) -> Array[Vector2i]:
	var positions = []
	var pixel_position = get_pixel_position_in_quad_from_lrtd(image_width, image_height)
	var brush_size = int(radius_distance_as_width_percent * image_width / 2)
	if pixel_position.x < 0 or pixel_position.y < 0:
		return positions
	for x in range(-brush_size, brush_size + 1):
		for y in range(-brush_size, brush_size + 1):
			var sample_position = Vector2i(pixel_position.x + x, pixel_position.y + y)
			var distance = sqrt(x * x + y * y)
			if distance <= brush_size and sample_position.x >= 0 and sample_position.x < image_width and sample_position.y >= 0 and sample_position.y < image_height:
				positions.append(sample_position)
	return positions

func get_pixels_color_from_image(image:Image) -> Array[Color]:
	var positions := get_pixels_position_in_quad_from_lrtd(image.get_width(), image.get_height())
	var colors = [] 
	for pos in positions:
		colors.append(image.get_pixelv(pos))
	return colors
