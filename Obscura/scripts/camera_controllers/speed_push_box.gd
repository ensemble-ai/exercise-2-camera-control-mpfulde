class_name SpeedUpPushBox
extends CameraControllerBase

@export var push_ratio :float
@export var pushbox_top_left: Vector2 
@export var pushbox_bottom_right: Vector2
@export var speedup_zone_top_left : Vector2 
@export var speedup_zone_bottom_right : Vector2

var _x_speed : bool = false
var _z_speed : bool = false
var _x_zone : bool = false
var _z_zone : bool = false

func _ready() -> void:
	super()
	position = target.position
	

func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()
	
	var tpos = target.global_position
	var cpos = global_position
	
	

	#boundary checks for pushbox
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
