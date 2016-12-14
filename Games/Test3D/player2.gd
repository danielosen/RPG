extends KinematicBody

### Gamepad States ###
var bool_controller_playstation = true
var bool_controller_keyboard = false
var joystick_motion = Vector2()
export var  joystick_input_sensitivity = 0.1
### End Gamepad States ###

### Movement States ###
var bool_is_moving_forward = false
var bool_is_moving_backward = false
var bool_is_strafing_left = false
var bool_is_strafing_right = false
### End Movement States ###

### Collision States ###
var bool_is_on_ground = false
var bool_is_on_slope = false
var bool_is_falling = false
### End Collision States ###

### Gravity and Jump States ###
var bool_is_jumping = false
var jump_time = 0.0
var jump_force = 2.0
var grav_time = 0.0
var grav_force = 1.7
### End Gravityy States ###

### Node Loading ###
onready var mesh = get_node("PlayerMesh")
onready var camera = get_node("PlayerCamera")
onready var ray_down = get_node("PlayerRayDown")
### End Node Loading ###

### Init Node ###
func _ready():
	set_process_input(true)
	set_fixed_process(true)
	pass
### End Init Node ###

### Parse Input ###
func _input(event):
	if bool_controller_keyboard:
		if event.type == InputEvent.KEY:
			if event.scancode == KEY_W:
				bool_is_moving_forward = event.is_pressed()
			elif event.scancode == KEY_S:
				bool_is_moving_backward = event.is_pressed()
			elif event.scancode == KEY_A:
				bool_is_strafing_left = event.is_pressed()
			elif event.scancode == KEY_D:
				bool_is_strafing_right = event.is_pressed()
			elif event.scancode == KEY_SPACE:
				if bool_is_jumping == false and bool_is_on_ground == true:
					bool_is_jumping = true
	elif bool_controller_playstation:
		if event.type == InputEvent.JOYSTICK_MOTION:
			#parses two events at the same time
			#axis 1 up -1 to down +1, axis 0 left -1 to right +1
			if event.axis == 0:
				if abs(event.value) >= joystick_input_sensitivity:
					joystick_motion.x = event.value
				else:
					joystick_motion.x = 0
			if event.axis == 1:
				if abs(event.value) >= joystick_input_sensitivity:
					joystick_motion.y = event.value
				else:
					joystick_motion.y = 0
		if event.type == InputEvent.JOYSTICK_BUTTON:
			if event.button_index == 0: #sony x button
				if bool_is_jumping == false and bool_is_on_ground == true:
					bool_is_jumping = true
				
	pass
### End Parse Input ###

### Process Input ###
func _fixed_process(delta):
	#Get transformation states
	#camera basis is not orthonormal, only orthogonal
	var cameraForward = -camera.get_transform().basis.z
	cameraForward.y = 0
	var cameraLeft = -camera.get_transform().basis.x
	var meshForward = -mesh.get_transform().basis.z
	var meshLeft = -mesh.get_transform().basis.x
	meshLeft.y = 0
	meshForward.y = 0
	var angle = atan2(cameraForward.x,-cameraForward.z)
	
	#Process Movement
	if bool_controller_keyboard:
		if bool_is_moving_forward:
			rotate_mesh(angle)
			move(meshForward)
		elif bool_is_moving_backward:
			#rotate_mesh_to_camera(PI+angle)
			move(-meshForward)
		elif bool_is_strafing_left:
			#rotate_mesh(angle-PI/2)
			#move(meshForward)
			move(meshLeft)
		elif bool_is_strafing_right:
			#rotate_mesh(angle+PI/2)
			#move(meshForward)
			move(-meshLeft)
	elif bool_controller_playstation:
		#the ps controller isnt normalized for a given pressure
		#it seems to favor up and left on the lstick
		var joystick_speed = min(joystick_motion.length(),1.0)
		#camera basis vectors are not orthonormal..
		var mesh_motion = -joystick_motion.y*cameraForward-joystick_motion.x*cameraLeft
		var testangle = atan2(mesh_motion.x,-mesh_motion.z)
		if joystick_speed > 0:
			rotate_mesh(testangle)
			move(mesh_motion.normalized()*joystick_speed)
		
	#Process Collision
	grav_time += delta
	if ray_down.is_colliding():
		var n = ray_down.get_collision_normal()
		if n.y == 1.0 and n.x == 0 and n.z == 0:
			bool_is_on_ground = true
			grav_time = 0.0
	else:
		bool_is_on_ground = false
	
	#Process Gravity
	if bool_is_jumping == true:
		jump_time += delta
		move(Vector3(0,jump_force*pow(1-jump_time,2),0.0))
		bool_is_jumping = jump_time < 1.0
	else:
		jump_time = 0.0
	if bool_is_on_ground == false:
		move(Vector3(0,-grav_force*pow(grav_time,2),0))
### End Process Input ###


### Movement Functions ###
func rotate_mesh(var angle):
	var delta = get_fixed_process_delta_time()
	var current_rot = Quat(mesh.get_transform().basis)
	var target_rot = Quat(Vector3(0,1,0), angle)
	var smooth_rot = current_rot.slerp(target_rot, delta * 10)
	mesh.set_rotation(Matrix3(smooth_rot).get_euler())
### End Movement Functions ###