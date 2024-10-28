class_name Autoscroll
extends CameraControllerBase

@export var top_left : Vector2
@export var bottom_right : Vector2
@export var autoscroll_speed : Vector3
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
	
	# push character
	if target.global_position.x <= global_position.x - top_left.x:
		target.global_position.x = global_position.x - top_left.x
	
	if target.global_position.x >= global_position.x + bottom_right.x:
		target.global_position.x = global_position.x + bottom_right.x
	
	if target.global_position.z <= global_position.z - top_left.y:
		target.global_position.z = global_position.z - top_left.y
		
	if target.global_position.z >= global_position.z + bottom_right.y:
		target.global_position.z = global_position.z + bottom_right.y
	
	if global_position.x - top_left.x < -map.width / 2.0:
		global_position.x = top_left.x - map.width / 2.0
		
	if global_position.x + bottom_right.x >= map.width / 2.0:
		global_position.x = map.width / 2.0 - bottom_right.x
		
	if global_position.z - top_left.y < -map.height / 2.0:
		global_position.z = top_left.y - map.heigh / 2.0 
	
	print(global_position)
	print(target.global_position)
	
	super(delta)

func reset_camera_pos() -> void:
	position = target.position
