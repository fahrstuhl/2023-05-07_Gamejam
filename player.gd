extends CharacterBody2D
class_name Player

signal spawn_rocket

var PLAYER_ID: int = -1 
const SPEED = 1000.0
const JUMP_BUFFER_MAX = 10
const COYOTE_TIME_MAX = 10
const SHOOT_COOLDOWN = 30
const MAX_JUMP_HEIGHT = int(6.5*Constants.TILE_SIZE)
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

var shoot_time = 0

func _ready():
	$ContactBox.connect("body_entered", _on_body_entered)
	$Sprite.texture = Constants.sprites[PLAYER_ID]

func _on_body_entered(body):
	if body is Rocket:
		body.explode()

func _physics_process(delta):
	if is_on_floor():
		coyote_time = COYOTE_TIME_MAX
		is_jumping = false
		jump_pressed = 0

	if not is_on_floor() and coyote_time == COYOTE_TIME_MAX:
		coyote_y = position.y

	# Handle Jump.
	if Input.is_action_just_pressed(fa("jump")):
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

	if Input.is_action_pressed(fa("jump")) and is_jumping and jump_pressed < MAX_JUMP_PRESSED_TIME:
		jump_pressed += 1

	if Input.is_action_just_released(fa("jump")) and is_jumping:
		velocity.y -= (JUMP_VELOCITY_MAX-JUMP_VELOCITY_MIN) * (1-jump_pressed/float(MAX_JUMP_PRESSED_TIME))
		jump_pressed = 0
		is_jumping = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis(fa("move_left"), fa("move_right"))
	if direction:
		velocity.x = move_toward(velocity.x, round(direction) * SPEED, SPEED/5)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if move_and_slide():
		pass
	
	var aim = Input.get_vector(fa("aim_left"), fa("aim_right"), fa("aim_down"), fa("aim_up"))
	var aim_angle = atan2(aim.x, aim.y)
	$Weapon.rotation = aim_angle
	if Input.is_action_pressed(fa("shoot")):
		if shoot_time == 0:
			emit_signal("spawn_rocket", $Weapon/Muzzle.global_position, aim_angle, PLAYER_ID)
			shoot_time = SHOOT_COOLDOWN

	if shoot_time > 0:
		shoot_time -= 1
	elif shoot_time < 0:
		shoot_time = 0

# Format action
func fa(action: StringName) -> StringName:
	return "{0}_{1}".format([action, PLAYER_ID])
