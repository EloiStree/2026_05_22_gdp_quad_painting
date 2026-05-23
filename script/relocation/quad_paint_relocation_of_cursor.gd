@tool

## This class allows you to ask information about where is your spherical cursor in relation to the quad.
## It will give you the position of the cursor in local space of the quad,
## but also in percent of the width of the quad.
## Helping you to draw on a quad or ask what pixel should be on the image.
class_name QuadPaintRelocationInfoOfGivenCursor
extends Node


@export var down_left_anchor:Node3D
@export var top_right_anchor:Node3D


@export_group("Debug")
@export var click_me_to_refresh_values:bool:
	set(value):
		_refresh_values()

@export var top_right_local_position:Vector3
@export var width_distance:float
@export var height_distance:float

func _process(delta: float) -> void:
	_refresh_values()

func _refresh_values():
	top_right_local_position = relocate_point_from_node_point(down_left_anchor, top_right_anchor)
	width_distance = top_right_local_position.x
	height_distance = top_right_local_position.z

	


func get_local_position_of_point(global_position:Vector3)->Vector3:
	return relocate_point(down_left_anchor, global_position)

func get_local_percent_position_of_point_based_on_width_lrdt(global_position:Vector3)->Vector3:
	var local_position = relocate_point(down_left_anchor, global_position)
	return Vector3(local_position.x / width_distance, local_position.y , local_position.z/ width_distance)

func get_local_percent_position_of_point_based_on_width_lrtd(global_position:Vector3)->Vector3:
	var percent_point =get_local_percent_position_of_point_based_on_width_lrdt(global_position)
	percent_point.z = 1.0-percent_point.z
	return percent_point

func relocate_point_from_node_point( cartesian:Node3D, point:Node3D)->Vector3:
	return relocate_point(cartesian, point.global_position)

func relocate_point( cartesian:Node3D, point:Vector3)->Vector3:
	var cartesian_position:Vector3 = cartesian.global_transform.origin
	var cartesian_quaternion:Quaternion = cartesian.global_transform.basis.get_rotation_quaternion()
	var relocated_point:Vector3 = point - cartesian_position
	var rotated_point:Vector3 = cartesian_quaternion * relocated_point
	rotated_point.z = -rotated_point.z
	return rotated_point


func get_cursor_info_in_resource(cursor_center_anchor:Vector3,radius:float,result_in_resources:SphereCursorPositionInfo)->void:
	_refresh_values()
	result_in_resources.cursor_center_anchor= cursor_center_anchor
	result_in_resources.radius_distance= radius
	result_in_resources.cursor_local_position = relocate_point(down_left_anchor, cursor_center_anchor)
	result_in_resources.percent_width_lrdt = get_local_percent_position_of_point_based_on_width_lrdt(cursor_center_anchor)
	result_in_resources.percent_width_lrtd = get_local_percent_position_of_point_based_on_width_lrtd(cursor_center_anchor)
	result_in_resources.quad_width = width_distance
	result_in_resources.quad_height = height_distance

	result_in_resources.diameter_distance = result_in_resources.radius_distance * 2
	result_in_resources.radius_distance_as_width_percent = result_in_resources.radius_distance / width_distance
	result_in_resources.diameter_distance_as_width_percent = result_in_resources.diameter_distance / width_distance
	result_in_resources.touching_radius= get_vertical_contact_radius_as_meter(result_in_resources.cursor_local_position.y, result_in_resources.radius_distance)
	result_in_resources.touching_radius_as_width_percent = result_in_resources.touching_radius / width_distance
	result_in_resources.touching_diameter = result_in_resources.touching_radius * 2
	result_in_resources.touching_diameter_as_width_percent = result_in_resources.touching_diameter / width_distance
	result_in_resources.is_touching_quad = is_touching_quad(cursor_center_anchor, radius)

#--------------------------


## Check it the point is between the four walls of the quad on a local plan.
func is_cursor_center_in_boundary(cursor_center_anchor:Vector3) -> bool:
	var local_position = relocate_point(down_left_anchor, cursor_center_anchor)
	return local_position.x >= 0.0 and local_position.y >= 0.0 and local_position.x <= width_distance and local_position.y <= height_distance

func is_cursor_touching_the_boundary_from_outside_the_quad_or_in(cursor_center_anchor:Vector3, radius:float) -> bool:
	if is_cursor_center_in_boundary(cursor_center_anchor):
		return true
	var local_position = relocate_point(down_left_anchor, cursor_center_anchor)
	if local_position.x < 0.0 and local_position.x + radius >= 0.0:
		return true
	if local_position.y < 0.0 and local_position.y + radius >= 0.0:
		return true
	if local_position.x > width_distance and local_position.x - radius <= width_distance:
		return true
	if local_position.y > height_distance and local_position.y - radius <= height_distance:
		return true
	return false


func has_vertical_contact_with_quad(cursor_center_anchor:Vector3,radius:float) -> bool:
	var local_position = relocate_point(down_left_anchor, cursor_center_anchor)
	var contact_radius_as_meter = get_vertical_contact_radius_as_meter(local_position.y, radius)
	return contact_radius_as_meter > 0.0

func is_touching_quad(cursor_center_anchor:Vector3,radius:float) -> bool:
	return is_cursor_touching_the_boundary_from_outside_the_quad_or_in(cursor_center_anchor, radius) and has_vertical_contact_with_quad(cursor_center_anchor, radius)


	
	

## For an other class
#func set_brush_size_with_local_size(size:float):
	#var local_size_vector3: Vector3 = Vector3(size, size, size)
	#size_anchor_sphere_brush.scale = local_size_vector3

#func set_brush_size_with_local_from_percent_01( percent_01:float):
	#var width_as_meter: float = get_quad_width_as_meter()
	#var size_as_meter: float = width_as_meter * percent_01
	#set_brush_size_with_local_size(size_as_meter)



#
#func get_cursor_lrdt_percent_01() -> Vector2:
	#var local_point: Vector2 = get_local_point_in_quad_vector2(drawing_point_center.global_position)
	#return Vector2(
		#local_point.x / get_quad_width_as_meter(),
		#-local_point.y / get_quad_height_as_meter()
	#)
#
#
func get_vertical_contact_radius_as_meter(point_height:float, point_radius:float,) -> float:
	if point_height> point_radius:
		return 0.0
	
	## By removing height of the radius we know if there is contact and we can continue
	var height_left_passed_plane = abs(point_radius) - abs(point_height)
	if height_left_passed_plane < 0.0:
		## No contact so we return 0
		return 0.0

	## if we remove  the tip cut of the raidus, we have the height before contact
	var height_plant_to_center = abs(point_radius) - height_left_passed_plane	
	## We want to play in 01 percent for trigonometry so we divide it by radius
	var height_left_normalized = height_plant_to_center / point_radius
	## To be readable by other developer we can store the info in name of the trigono formula
	var adjacent_edge = height_left_normalized
	var hypothenus_edge =1.0
	## We can use pythagorean theorem to find the opposed edge that is the contact radius as meter
	var opposed_edge = sqrt(hypothenus_edge*hypothenus_edge - adjacent_edge*adjacent_edge)
	## Now we nee to give back the value in real measurement.
	var contact_radius_as_meter = point_radius * opposed_edge
	return contact_radius_as_meter

#
#func get_contact_radius_percent_01_from_width() -> float:
	#return get_contact_radius_as_meter() / get_quad_width_as_meter()
#
#
#
#func get_cursor_radius_percent_01() -> float:
	#return get_cursor_radius_as_meter() / get_quad_width_as_meter()
#
#
#func get_cursor_height() -> float:
	#var cursor_position: Vector3 = get_local_point_in_quad_vector3(drawing_point_center.global_position)
	#return cursor_position.y
#
#func get_cursor_up_pression_percent_11() -> float:
	#var height: float = get_cursor_height()
	#var radius: float = get_cursor_radius_as_meter()
	#if abs(height) > radius:
		#return 0.0
#
	#var percent_to_center: float = height/radius
	#if percent_to_center > 0.0:
		#return 1.0 - percent_to_center
	#if percent_to_center < 0.0:
		#return -1.0 - percent_to_center
#
	#return 0.0
#
#
#
#
## func _process(delta: float) -> void:
## 	## print widht height
## 	print("")
## 	# print("Width: "+str(get_quad_width_as_meter())+" Height: "+str(get_quad_height_as_meter()))
## 	# print("Diameter: "+str(get_quad_diameter_as_meter()))
## 	# print("cursor lrdt percent 01: "+str(get_cursor_lrdt_percent_01()))
## 	# print("Local point in quad: "+str(get_local_point_in_quad_vector3(drawing_point_center.global_position)))
## 	# print("Pression percent 11: "+str(get_cursor_up_pression_percent_11()))
## 	# print ("Cursor Height: ",str(get_cursor_height(), " Cursor Radius: "+str(get_cursor_radius_as_meter()))
#
## 	# print ("Cursor Radius Percent 01: "+str(get_cursor_radius_percent_01()))
## 	# print ("Contact Radius Percent 01 from width: "+str(get_contact_radius_percent_01_from_width()))	
	#
## 	# print("Height: "+str(height)+" Radius: "+str(radius))
## 	# print("Height left: "+str(height_plant_to_center))
## 	# print("Contact radius as meter: "+str(contact_radius_as_meter))
#
#
#func get_quad_diameter_as_meter() -> float:
	#return (right_top_anchor.global_position - left_down_anchor.global_position).length()
#
#func get_quad_height_as_meter() -> float:
	#return (left_down_anchor.global_position - left_top_anchor.global_position).length()
#
#func get_quad_width_as_meter() -> float:
	#return (right_top_anchor.global_position - left_top_anchor.global_position).length()
	#
#func get_cursor_radius_as_meter() -> float:
	#return (drawing_radius_center.global_position - drawing_point_center.global_position).length()
#
#func get_cursor_diameter_as_meter() -> float:
	#return get_cursor_radius_as_meter() * 2.0
#
#
#
#
#
#
#var  quaternion_rotation_180:= Quaternion.from_euler(Vector3(0.0, 180.0, 0.0))
#func get_local_point_in_quad_vector3(point:Vector3) -> Vector3:
	#var relative_point: Vector3 = point - left_down_anchor.global_position
	#var inverse_rotation: Quaternion = Quaternion.from_euler(left_down_anchor.global_rotation).inverse()
	#var local_point: Vector3 = inverse_rotation*relative_point
	#return local_point
#
#
#
#func get_local_point_in_quad_vector2(point:Vector3) -> Vector2:
	#var local_point: Vector3 = get_local_point_in_quad_vector3(point)
	#return Vector2(local_point.x, local_point.z)
	#
