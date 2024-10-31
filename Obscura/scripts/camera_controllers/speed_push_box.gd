class_name SpeedUpPushBox
extends CameraControllerBase

# defaulted to tested values
@export var push_ratio :float = 0.95 # should be lower, but this helps visually seeing it works
@export var pushbox_top_left: Vector2 = Vector2(10, 10)
@export var pushbox_bottom_right: Vector2 = Vector2(10, 10)
@export var speedup_zone_top_left : Vector2  = Vector2(3, 3) # both of these should be bigger but helps see it works 
@export var speedup_zone_bottom_right : Vector2 = Vector2(3, 3)

# zone information
# in opposite speed zone but not own speed zone (for example top middle zone allow x movement)
var _x_speed : bool = false
var _z_speed : bool = false

# in both own and opposite speed zone (corner boxes of speed zone/overlap area)
var _x_zone : bool = false
var _z_zone : bool = false

func _ready() -> void:
	super()
	position = target.position
	

func _process(delta: float) -> void:
	if !current:
		reset_camera_pos()
		return
	
	if draw_camera_logic:
		# print outer push box
		draw_logic()
		# print speed zone inner box at 50% opacity
		draw_speed_zone()
	
	var tpos = target.global_position
	var cpos = global_position

	#boundary checks for pushbox
	#if within boundary check if in the speedzone and handle inputs appropriately
	# 2 types of speedzone checks 
	# 1. for x and z if in opposite speed zone (x in z speed zone)
	# 2. if in 2 speed zones at once (corner boxes)
	# logic for checking if a speed zone was entered is the same boundary check but on the speedzone box
	#left
	var diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - (cpos.x - pushbox_top_left.x)
	if diff_between_left_edges < 0:
		_x_speed = false
		_x_zone = true
		global_position.x += diff_between_left_edges
	else:
		_z_speed = true
		diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - (cpos.x - speedup_zone_top_left.x)
		if diff_between_left_edges < 0:
			_x_speed = false
			_x_zone = true
			if target.velocity.x < 0 or _z_zone:
				global_position.x += target.velocity.x * push_ratio * delta
		else:
			_z_speed = false
			_x_zone = false
	#right
	var diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - (cpos.x + pushbox_bottom_right.x)
	if diff_between_right_edges > 0:
		_x_speed = false
		_x_zone = true
		global_position.x += diff_between_right_edges
	else:
		_z_speed = true
		diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - (cpos.x + speedup_zone_bottom_right.x)
		if diff_between_right_edges > 0:
			_x_speed = false
			_x_zone = true
			if target.velocity.x > 0 or _z_zone:
				global_position.x += target.velocity.x * push_ratio * delta
		elif not diff_between_left_edges < 0:
			_z_speed = false
			_x_zone = false
	#top
	var diff_between_top_edges = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - pushbox_top_left.y)
	if diff_between_top_edges < 0:
		_z_speed = false
		_z_zone = true
		global_position.z += diff_between_top_edges
	else:
		if not diff_between_left_edges < 0 and not diff_between_right_edges > 0:
			_x_speed = true
		diff_between_top_edges = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - speedup_zone_top_left.y)
		if diff_between_top_edges < 0:
			_z_zone = true
			_z_speed = false
			if target.velocity.z < 0 or _x_zone:
				global_position.z += target.velocity.z * push_ratio * delta
		else:
			_x_speed = false
			_z_zone = false
	#bottom
	var diff_between_bottom_edges = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + pushbox_bottom_right.y)
	if diff_between_bottom_edges > 0:
		_z_speed = false
		_z_zone = true
		global_position.z += diff_between_bottom_edges
	else:
		if not diff_between_left_edges < 0 and not diff_between_right_edges > 0:
			_x_speed = true
		diff_between_bottom_edges = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + speedup_zone_bottom_right.y)
		if diff_between_bottom_edges > 0:
			_z_speed = false
			_z_zone = true
			if target.velocity.z > 0 or _x_zone:
				global_position.z += target.velocity.z * push_ratio * delta
		elif not diff_between_top_edges < 0:
			_x_speed = false
			_z_zone = false
			
			

	if _z_speed:
		global_position.z += target.velocity.z * push_ratio * delta
	
	if _x_speed:
		global_position.x += target.velocity.x * push_ratio * delta
	
	super(delta)


func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var left:float = -pushbox_top_left.x
	var right:float = pushbox_bottom_right.x
	var top:float = -pushbox_top_left.y
	var bottom:float = pushbox_bottom_right.y
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()

func draw_speed_zone() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var left:float = -speedup_zone_top_left.x
	var right:float = speedup_zone_bottom_right.x
	var top:float = -speedup_zone_top_left.y
	var bottom:float = speedup_zone_bottom_right.y
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	material.transparency = 1 # enables transparency with the alpha value
	material.albedo_color.a = 0.5
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
	
func reset_camera_pos() -> void:
	position = target.position
