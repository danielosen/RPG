extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
#masse dritt som skal bort herfra
var vector_move_direction = Vector3(0.0,0.0,0.0)
var key_move_forward = KEY_W
var key_move_backward = KEY_S
var key_move_jump = KEY_SPACE
var key_move_right = KEY_D
var key_move_left = KEY_A
var key_move_array = [key_move_forward,key_move_backward,key_move_jump]
var orientation = Vector3(0.0,0.0,0.0)
var bool_is_moving = false
var bool_is_jumping = false

var pressed = false
var last_position = Vector2()


### PLAYER POSITION ###
var old_position = get_translation()
var current_position = old_position

## PLAYER MOVEMENT SPEED ###
var old_movespeed = 0.0
var current_movespeed = 0.0
var max_movespeed = 1.4
var framespeed = 0.0

### PLAYER MOVEMENT ACCELERATION ###
var max_moveaccel = 0.7
var current_moveaccel = 0.0
var current_gravitytime = 0.0
var max_movedeaccel = 2.1
var const_gravity = 2.0
### PLAYER COLLISION ###
var collision_normal = Vector3(0.0,0.0,0.0)
var collision_angle = 0.0
var collision_max_slope_angle = 30*PI/180



### CALLED INIT WHEN NODE IS ADDED TO SCNENE ###
func _ready():
	# Enable Input Processing
	set_process_input(true)
	set_process_unhandled_input(true)
	# Enable fixed process
	set_fixed_process(true)
	pass
	
### EAT PLAYER INPUT ###
func _input(event):
	if( event.type == InputEvent.KEY):
		if event.scancode in key_move_array:
			orientation = self.get_rotation()
			if event.scancode == key_move_forward:
				vector_move_direction.z = cos(orientation.y-orientation.x)
				vector_move_direction.x = sin(orientation.y)
			if event.scancode == key_move_backward:
				vector_move_direction.z = -cos(orientation.y-orientation.x)
				vector_move_direction.x = -sin(orientation.y)
			if event.scancode == key_move_jump:
				bool_is_jumping = event.is_pressed()
			bool_is_moving = event.is_pressed()

### EAT UNHANDLED INPUT ### (events that are not currently handled by other nodes) 
func _unhandled_input(event):
    if event.type == InputEvent.MOUSE_BUTTON:
        pressed = event.is_pressed()
        if pressed:
            last_position = event.pos
    elif event.type == InputEvent.MOUSE_MOTION and pressed:
        var delta = event.pos - last_position
        last_position = event.pos
        self.rotate_y(-delta.x * 0.01)

#LOOP EVERY FIXED FRAME (PHYSICS)
func _fixed_process(delta):
	
	# Acceleration and Deacceleration
	if bool_is_moving:
		if current_movespeed < max_movespeed:
			current_movespeed += delta*max_moveaccel
	else:
		if current_movespeed > 0:
			if current_movespeed < 0.1:
				current_movespeed = 0.0
			else:
				current_movespeed -= delta*max_movedeaccel
	
	# Collision and Translation
	old_position = current_position
	if current_gravitytime < 1.0:
		current_gravitytime += delta
	if is_colliding():
		collision_normal = get_collision_normal()
		collision_angle = collision_normal.angle_to(Vector3(0.0,1.0,0.0))
		if collision_angle < collision_max_slope_angle:
			current_gravitytime = 0.0
			#sliding seems bugged at all angles greater than 0...
			#print(vector_move_direction.cross(collision_normal))
			#Normalizing causes jittery movement
			#Unsure how to avoid speed loss
			vector_move_direction = collision_normal.slide(vector_move_direction)
			if collision_angle > 0.0: #the slide calculation is a bit too exact, causes jittery movement ? 
				pass
			#Project movement direction
		else:
			#Climbing?
			pass
		
	#Gravity and Jump
	if bool_is_jumping:
		if current_gravitytime <= 0.1:
			if is_colliding() == false:
				move(Vector3(0.0,1.0,0.0)*const_gravity*pow(1.0,2))
	move(vector_move_direction*current_movespeed)
	move(Vector3(0.0,-1.0,0.0)*const_gravity*pow(current_gravitytime,2))
	current_position = get_translation()
	# Update Speed Along Ground
	framespeed = (current_position-old_position).length()/delta
	
