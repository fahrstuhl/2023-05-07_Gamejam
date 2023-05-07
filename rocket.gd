extends CharacterBody2D
class_name Rocket

signal spawn_explosion

var exploded = false

var TILES_PER_SECOND := 80
var speed := 0.0
var PLAYER_ID := -1

func _ready():
	speed = TILES_PER_SECOND * Constants.TILE_SIZE

func _physics_process(delta):
	var collision := move_and_collide(Vector2.UP.rotated(global_rotation) * speed * delta)
	if collision:
		explode()

func explode():
	if exploded:
		return
	exploded = true
	print("spawn_explosion: {0}, {1}".format([global_position, PLAYER_ID]))
	emit_signal("spawn_explosion", global_position, PLAYER_ID)
	queue_free()
