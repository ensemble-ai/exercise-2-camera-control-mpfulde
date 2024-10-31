class_name Autoscroll
extends CameraControllerBase

#defaulted to tested values
@export var top_left : Vector2 = Vector2(10, 10)
@export var bottom_right : Vector2 = Vector2(10, 10)
@export var autoscroll_speed : Vector3 = Vector3(-0.1, 0.0, -0.1)
@export var map : TerrainManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	position = target.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !current:
		reset_camera_pos()
		return
	
	if draw_camera_logic:
		draw_logic()
	
	global_position += autoscroll_speed
	
	# attempted way to keep camera in line with the map dimension
	# does not work as intended when zoomed very out or very in
	global_position.x = clamp(global_position.x, -map.width/2.0 + top_left.x + 20, map.width/2.0 - bottom_right.x - 20)
	global_position.z = clamp(global_position.x, -map.height/2.0 + top_left.y + 20, map.height/2.0 - bottom_right.y - 20)
	
	var tpos = target.global_position
	var cpos = global_position
	
	#boundary checks
	#similar to push_box however if the target exceeds the bounds move the target back into bounds
	#rather than move the camera to keep up with target
	#left
	var diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - (cpos.x - top_left.x)
	if diff_between_left_edges < 0:
		target.global_position.x -= diff_between_left_edges
	#right
	var diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - (cpos.x + bottom_right.x)
	if diff_between_right_edges > 0:
		#pass
		target.global_position.x -= diff_between_right_edges
	#top
	var diff_between_top_edges = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - top_left.y)
	if diff_between_top_edges < 0:
		target.global_position.z -= diff_between_top_edges
	#bottom
	var diff_between_bottom_edges = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + bottom_right.y)
	if diff_between_bottom_edges > 0:
		target.global_position.z -= diff_between_bottom_edges
		
	super(delta)

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var left:float = -(top_left.x)
	var right:float = (bottom_right.x)
	var top:float = -(top_left.y)
	var bottom:float = (bottom_right.y)
	
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

func reset_camera_pos() -> void:
	position = target.position
