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
	follow_speed = 0.25 * target.BASE_SPEED
	catchup_speed = 0.5 * target.BASE_SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()
		
	
	var speed_x := follow_speed
	var speed_z := follow_speed
	var tpos := target.global_position
	var cpos := global_position
	

	
	if is_zero_approx(target.velocity.x):
		speed_x = catchup_speed
	
	if is_zero_approx(target.velocity.z):
		speed_z = catchup_speed
		
	if abs(tpos.x - cpos.x) > leash_distance:
		#if $vessel/ParticleTrail.visible:
			#speed_x = target.HYPER_SPEED
		#else:
		speed_x = 3 * target.BASE_SPEED
		
	if abs(tpos.z - cpos.z) > leash_distance:
		#if $vessel/ParticleTrail.visible:
			#speed_x = target.HYPER_SPEED
		#else:
		
		speed_z = 3 * target.BASE_SPEED
		
	if abs(cpos.x - tpos.x) <= 0.25:
		speed_x = 0.0
		
	if abs(cpos.z - tpos.z) <= 0.25:
		speed_z = 0.0
	
	if tpos.x < cpos.x:
		speed_x *= -1

	if tpos.z < cpos.z:
		speed_z *= -1
		
	var speed : Vector3 = Vector3(speed_x, 0.0, speed_z)

	#print(tpos)
	print(speed)
	var offset = tpos-cpos

	print(offset)
	global_position.x += speed.x * delta
	global_position.z += speed.z * delta
	
	if (abs(offset.x) <= 0.25) and not is_zero_approx(offset.x):
		global_position.x = move_toward(cpos.x, tpos.x, 1)
	
	if (abs(offset.z) <= 0.25) and not is_zero_approx(offset.x):
		global_position.z = lerp(cpos.z, tpos.z, 1)
	
	

	if (offset.x > (leash_distance - .1)):
		global_position.x = move_toward(cpos.x, tpos.x - leash_distance + .2, 1)
	
	if (offset.z > (leash_distance - .1)):
		global_position.z = move_toward(cpos.z, tpos.z - leash_distance + .2, 1)
		
	if (offset.z < -(leash_distance - .1)):
		global_position.z = move_toward(cpos.z, tpos.z + leash_distance - .2, 1)
		
	if (offset.x < -(leash_distance - .1)):
		global_position.x = move_toward(cpos.x, tpos.x + leash_distance - .2, 1)

	
	
	
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
