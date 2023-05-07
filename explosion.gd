extends Area2D

signal hit_player_by
signal hit_rocket

var PLAYER_ID := -1
var ground := false

func _ready():
	$Animation.connect("animation_finished", finish)
	connect("body_entered", check_if_hit)
	$Animation.play("aerial")
	for body in get_overlapping_bodies():
		check_if_hit(body)

func finish():
	queue_free()

func check_if_hit(body: Node2D):
	print(body is Rocket)
	if body is Player:
		emit_signal("hit_player_by", body.PLAYER_ID, PLAYER_ID)
	if body is Rocket:
		emit_signal("hit_rocket", PLAYER_ID, body)
