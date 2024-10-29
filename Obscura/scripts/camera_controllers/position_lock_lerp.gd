class_name PositionLockLerp
extends CameraControllerBase

@export var follow_speed : float
@export var catchup_speed : float
@export var leash_distance : float 
@export var cross_width : int = 5

var _last_pos : Vector3

func _ready() -> void:
	super()
	position = target.position
	_last_pos = target.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()
		
	
	var speed_x := follow_speed * target.BASE_SPEED
	var speed_z := follow_speed * target.BASE_SPEED
	var tpos := target.global_position
	var cpos := global_position
	
	var offset = tpos-cpos

	
	if is_zero_approx(target.velocity.x):
		speed_x = catchup_speed * target.BASE_SPEED
	
	if is_zero_approx(target.velocity.z):
		speed_z = catchup_speed * target.BASE_SPEED
		
	if abs(tpos.x - cpos.x) > leash_distance:
		if target.dashing:
			speed_x = target.HYPER_SPEED
		else:
			speed_x = 3 * target.BASE_SPEED
		
	if abs(tpos.z - cpos.z) > leash_distance:
		speed_z = 10 * (offset.z) / delta
		#if target.dashing:
			#speed_z = 3 * target.HYPER_SPEED
		#else:
			#speed_z = 3 * target.BASE_SPEED
		
	if abs(cpos.x - tpos.x) <= (speed_x / target.BASE_SPEED) - .05:
		speed_x = 0.0
		
	if abs(cpos.z - tpos.z) <= (speed_z / target.BASE_SPEED) - .05:
		speed_z = 0.0
	
	if tpos.x < cpos.x:
		speed_x *= -1

	if tpos.z < cpos.z:
		speed_z *= -1
		
	var speed : Vector3 = Vector3(speed_x, 0.0, speed_z)

	#print(tpos)
	#print(offset)
	#print(speed/target.BASE_SPEED)
	global_position.x += speed.x * delta
	global_position.z += speed.z * delta
	
	#print(is_zero_approx(offset.x))
	#print(is_zero_approx(offset.z))
	#print(tpos)
	#print(global_position)
	if (speed.x == 0) and not is_zero_approx(offset.x):
		global_position.x = tpos.x
	
	if (speed.z == 0) and not is_zero_approx(offset.z):
		global_position.z = tpos.z
	
	

	if (offset.x > (leash_distance - .1)):
		#global_position.x = move_toward(cpos.x, tpos.x - leash_distance + .2, 1)
		global_position.x = tpos.x - leash_distance + .2
	
	if (offset.z > (leash_distance - .1)):
		#global_position.z = move_toward(cpos.z, tpos.z - leash_distance + .2, 1)
		global_position.z = tpos.z - leash_distance + .2
		
	if (offset.z < -(leash_distance - .1)):
		#global_position.z = move_toward(cpos.z, tpos.z + leash_distance - .2, 1)
		global_position.z = tpos.z + leash_distance - .2
		#print(global_position)
		
	if (offset.x < -(leash_distance - .1)):
		#global_position.x = move_toward(cpos.x, tpos.x + leash_distance - .2, 1)
		global_position.x = tpos.x + leash_distance - .2
		#print(global_position)

	
	
	
	super(delta)
	_last_pos = tpos
	
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
