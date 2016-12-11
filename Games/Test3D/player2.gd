extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var bool_is_moving_forward = false
var bool_is_moving_backward = false
onready var mesh = get_node("PlayerMesh")
onready var camera = get_node("PlayerCamera")
func _ready():
	set_process_input(true)
	set_fixed_process(true)
	#init camera_facing
	pass

func _input(event):
	if event.type == InputEvent.KEY:
		if event.scancode == KEY_W:
			bool_is_moving_forward = event.is_pressed()
		elif event.scancode == KEY_S:
			bool_is_moving_backward = event.is_pressed()
	pass
func _fixed_process(delta):
	
	var cameraForward = -camera.get_transform().basis.z
	cameraForward.y = 0
	var playerForward = -mesh.get_transform().basis.z
	playerForward.y = 0
	var angle = cameraForward.angle_to(playerForward)
	if is_nan(angle):
		angle = 0
	var z_diff = cameraForward.z-playerForward.z
	if is_nan(z_diff):
		z_diff = 0
	var motion = cameraForward
	angle = atan2(motion.x,-motion.z)
	
	#print("angle: " +str(angle)+ "z_diff: " + str(z_diff))
	#mesh.rotate_y(sign(-z_diff)*angle)
	"""
	if is_nan(angle):
		angle = 0
	var z_diff = cameraForward.z-playerForward.z
	print("angle: " +str(angle)+ "z_diff: " + str(z_diff))
	while(angle*180/PI > 0.01):
		mesh.rotate_y(sign(-z_diff)*angle)
		pass
	"""
	#if abs(playerForward.angle_to(cameraForward)) > 1:
	#	look_at(get_translation()-cameraForward,Vector3(0,1,0));
	### next task, make player rotate in camera forward viewing direction
	
	if bool_is_moving_forward:
		Rotation(angle)
		move(playerForward)
	"""
	elif bool_is_moving_backward:
		var dir = facing.basis.z
		dir.y = 0
		move(get_transform().basis.x)
		#move(dir.basis.x)
		#look_at(dir+get_translation(),Vector3(0,1.0,0))
		#move(dir.normalized())
		
		#look_at(dir-get_translation(),Vector3(0,1.0,0))
		#move(get_rotation()))
		#rotate_y(dir.z*delta)
		"""
	pass
	
func Rotation(var angle):
    var delta = get_fixed_process_delta_time()
    var current_rot = Quat(mesh.get_transform().basis)
    var target_rot = Quat(Vector3(0,1,0), angle)
    var smooth_rot = current_rot.slerp(target_rot, delta * 10)
    mesh.set_rotation(Matrix3(smooth_rot).get_euler())