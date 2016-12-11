extends Camera

# Distance from the target
var radius = 10.0
var max_radius = 60.0
var min_radius = 5.0
# Here we assume the target will be the parent, but could be any node
onready var target = get_parent()
onready var mesh = get_parent().get_node("PlayerMesh")
# Horizontal angle
var _yaw = 0
# Vertical angle
var _pitch = 0

# The vertical angle must be limited otherwise we would be able to look upside down
var _pitch_min = -PI/2+0.4
var _pitch_max = PI/2-0.4

# How fast the camera moves when the mouse moves (in degrees per pixel)
var sensitivity = Vector2(1,1)

var pressed = false
var last_mouse_pos = Vector2()


func _ready():
    set_process_input(true)
    set_fixed_process(true)


# Technically not needed in the current scene,
# but would be needed if the camera was not a child of the avatar
func _fixed_process(delta):
	_update_transform()


func _update_transform():
	var target_pos = target.get_translation()
	# 3D trigonometry: calculate position from X and Y angles.
	# The 3rd one (Z, or roll) would not affect the position so we ignore it
	var pos = Vector3(cos(_yaw) * cos(_pitch), sin(_pitch), sin(_yaw) * cos(_pitch))
	# Adjust distance from target
	pos *= radius
	# Set the actual position and rotation.
	# (note: if a 3rd angle Z is needed, it would affect the up vector, last param)
	look_at_from_pos(target_pos + pos, target_pos, Vector3(0,1,0))


func _input(event):
	# Did the mouse move?
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_mask == 1:
			pressed = true
		elif event.button_mask == 0:
			pressed = false
		if event.button_index == 5:
			if radius < max_radius:
				radius += 1.0
		elif event.button_index == 4:
			if radius > min_radius:
				radius -= 1.0
	elif event.type == InputEvent.MOUSE_MOTION and pressed:
		# Get how many pixels it moved
		var rmotion = event.relative_pos
		# Apply this to rotations
		_yaw += rmotion.x * deg2rad(sensitivity.x)
		_pitch += rmotion.y * deg2rad(sensitivity.y)
		_pitch = clamp(_pitch, _pitch_min, _pitch_max)
		_update_transform()