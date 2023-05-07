@tool
extends Control

var PLAYER_ID = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = "Player: {0}".format([PLAYER_ID+1])
