class_name PositionLockLerp
extends CameraControllerBase

# defaulted to tested values
@export var follow_speed : float = 0.5
@export var catchup_speed : float = 3
@export var leash_distance : float  = 5
@export var cross_width : int = 5

var _speed : float
var _delta_sum : float

func _ready() -> void:
	super()
	position = target.position
	_speed = follow_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !current:
		reset_camera_pos()
		return
	
	_delta_sum += delta
	
	# this how i forced _process to update at the same rate as the target physics process (before i realized i could just limit the fps)
	if _delta_sum <= (target.cur_delta - target.last_delta):
		return
	else:
		_delta_sum = 0.0
	
	if draw_camera_logic:
		draw_logic()
		
	
	var speed := _speed
	var tpos := target.global_position
	var cpos := global_position
	var offset = tpos-cpos
	var direction = offset.normalized()
	

	if target.velocity == Vector3.ZERO:
		speed = catchup_speed
	else:
		speed = follow_speed
		
		
	if (abs(offset.x) >= leash_distance - .1) or (abs(offset.z) >= leash_distance - .1):
		if catchup_speed > 1:
			speed = catchup_speed
		else:
			speed = 1
	
	direction *= speed
	if target.dashing:
		direction *= target.HYPER_SPEED
	else:
		direction *= target.BASE_SPEED
	
	direction.y = 0
	# since framerate is fixed in project settings can just use delta here, but better safe than sorry
	global_position += direction * (target.cur_delta - target.last_delta)
	
	if (direction.x == 0) and not is_zero_approx(offset.x):
		global_position.x = tpos.x
	
	if (direction.z == 0) and not is_zero_approx(offset.z):
		global_position.z = tpos.z
	
	if (abs(offset.x) >= leash_distance - .1) or (abs(offset.z) >= leash_distance - .1):
		_bound_to_leash_circle(offset)
	
	
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
	
	
# locks player on leash if trying to exceed leash distance
# does not do anything if the offset is less than the leash distance
func _bound_to_leash_circle(offset: Vector3) -> void:
		
	var tpos := target.global_position

	if (offset.x > (leash_distance - .1)) and not is_zero_approx(target.velocity.x):
		global_position.x = tpos.x - leash_distance
	
	if (offset.z > (leash_distance - .1)) and not is_zero_approx(target.velocity.z):
		global_position.z = tpos.z - leash_distance
		
	if (offset.z < -(leash_distance - .1)) and not is_zero_approx(target.velocity.z):
		global_position.z = tpos.z + leash_distance
		
	if (offset.x < -(leash_distance - .1)) and not is_zero_approx(target.velocity.x):
		global_position.x = tpos.x + leash_distance
		
func reset_camera_pos() -> void:
	position = target.position
