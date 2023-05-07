extends Area2D

signal hit_player_by
signal hit_rocket

var PLAYER_ID := -1
var ground := false
var DANGER_TIME := 0.1

func _ready():
	$Danger.one_shot = true
	$Danger.connect("timeout", disable_damage)
	$Danger.start(DANGER_TIME)
	$Animation.connect("animation_finished", finish)
	connect("body_entered", check_if_hit)
	connect("area_entered", check_if_hit)
	$Animation.play("aerial")
	for body in get_overlapping_bodies():
		check_if_hit(body)
	for area in get_overlapping_areas():
		check_if_hit(area)

func finish():
	queue_free()

func disable_damage():
	$CollisionShape2D.disabled = true

func check_if_hit(collider: Node2D):
	if $Danger.is_stopped():
		return
	if collider.get_parent() is Player:
		emit_signal("hit_player_by", collider.get_parent().PLAYER_ID, PLAYER_ID)
	if collider is Rocket:
		emit_signal("hit_rocket", PLAYER_ID, collider)
