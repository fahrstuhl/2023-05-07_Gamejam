extends CharacterBody2D
class_name Player

var PLAYER_ID: int = -1 
const SPEED = 150.0
const JUMP_BUFFER_MAX = 10
const COYOTE_TIME_MAX = 10
const MAX_JUMP_HEIGHT = int(4.5*Constants.TILE_SIZE)
const MIN_JUMP_HEIGHT = int(1.5*Constants.TILE_SIZE)
const MAX_RISE_TIME = 0.5
const MAX_JUMP_PRESSED_TIME = 15

const GRAVITY = 2*MAX_JUMP_HEIGHT/pow(MAX_RISE_TIME, 2)
const JUMP_VELOCITY_MAX = -sqrt(2*float(MAX_JUMP_HEIGHT)*float(GRAVITY))
const JUMP_VELOCITY_MIN = -sqrt(2*float(MIN_JUMP_HEIGHT)*float(GRAVITY))

var jump_buffer = 0
var coyote_time = 0
var coyote_y
var is_jumping = false
var jump_pressed = 0


func _ready():
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(1, true)
#	$ContactBox.monitorable = false
	$ContactBox.set_collision_layer_value(1, false)
	$ContactBox.set_collision_mask_value(1, false)
	$ContactBox.set_collision_mask_value(3, true)
	$ContactBox.set_collision_mask_value(4, true)
	$ContactBox.connect("body_shape_entered", _on_contact)
	
func _on_contact(body_rid: RID, _body: Node2D, _body_shape_index, _local_shape_index):
	var layer_bitmap = PhysicsServer2D.body_get_collision_layer(body_rid)
	if layer_bitmap & 1<<2:
		if PLAYER_ID == 0:
			get_tree().reload_current_scene()
		else:
			queue_free()
	elif layer_bitmap & 1<<3:
		Constants.load_next_level()
	else:
		print("Unknown physics layer bitmap: ", layer_bitmap)

func _physics_process(delta):
	if is_on_floor():
		coyote_time = COYOTE_TIME_MAX
		is_jumping = false
		jump_pressed = 0

	if not is_on_floor() and coyote_time == COYOTE_TIME_MAX:
		coyote_y = position.y

	# Handle Jump.
	if Input.is_action_just_pressed("jump_"+str(PLAYER_ID)):
		jump_buffer = JUMP_BUFFER_MAX

	if jump_buffer > 0:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY_MAX
			jump_buffer = 0
			coyote_time = 0
			is_jumping = true
		elif coyote_time > 0:
			position.y = coyote_y
			coyote_y = null
			velocity.y = JUMP_VELOCITY_MAX
			jump_buffer = 0
			is_jumping = true
		else:
			jump_buffer -= 1
	else:
		if not is_on_floor() and coyote_time > 0:
			coyote_time -= 1

	if Input.is_action_pressed("jump_"+str(PLAYER_ID)) and is_jumping and jump_pressed < MAX_JUMP_PRESSED_TIME:
		jump_pressed += 1

	if Input.is_action_just_released("jump_"+str(PLAYER_ID)) and is_jumping:
		velocity.y -= (JUMP_VELOCITY_MAX-JUMP_VELOCITY_MIN) * (1-jump_pressed/float(MAX_JUMP_PRESSED_TIME))
		jump_pressed = 0
		is_jumping = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left_"+str(PLAYER_ID), "move_right_"+str(PLAYER_ID))
	if direction:
		velocity.x = move_toward(velocity.x, round(direction) * SPEED, SPEED/5)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if move_and_slide():
		for ray in [$RayLeft, $RayRight]:
			if ray.is_colliding():
				var collider = ray.get_collider()
				if collider.has_method("moving_platform_touched"):
					collider.moving_platform_touched()
