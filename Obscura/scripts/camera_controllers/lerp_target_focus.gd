class_name TargetFocusLerp
extends CameraControllerBase

# defaulted to tested values for how i like the speed
@export var lead_speed : float = 1.025 
@export var catchup_delay_duration : float = 0.5
@export var catchup_speed : float = 0.25
@export var leash_distance : float  = 3
@export var cross_width : int = 5

var _catchup_timer : float

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
	
	
	# much more simplified version of the lerp handler
	var speed := Vector3(lead_speed, 0, lead_speed)
	var offset := target.global_position - global_position
	var norm := offset.normalized()
	norm.y = 0
	
	var valid_x : bool = offset.x > leash_distance - .1 and target.velocity.x <= 0
	valid_x = valid_x or (offset.x < -(leash_distance + .1) and target.velocity.x >= 0)
	
	var valid_z : bool = offset.z > leash_distance - .1 and target.velocity.z <= 0
	valid_z = valid_z or (offset.z < -(leash_distance + .1) and target.velocity.z >= 0)
	
	# if outside the leash distance and not moving back into the camera
	if valid_x:
		speed.x = 1
	if valid_z:
		speed.z = 1

	speed.x *= target.velocity.x
	speed.z *= target.velocity.z
	
	global_position += speed * delta
	
	# if not moving start hte catchup timer and then reset camera
	if target.velocity == Vector3.ZERO:
		_catchup_timer += delta
		if _catchup_timer >= catchup_delay_duration:
			global_position += norm * target.BASE_SPEED * catchup_speed * delta
	
	else :
		_catchup_timer = 0
	
	super(delta)
	
func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var top := -cross_width
	var bottom := cross_width
	var left := -cross_width
	var right := cross_width
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(0, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, 0))
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
