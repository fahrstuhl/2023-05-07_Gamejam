@tool
extends Control

var PLAYER_ID = -1

const TEMPLATE = """
[font_size=64][color=green]{kills}[/color]
[color=red]{deaths}[/color][/font_size]
"""

var score: Dictionary:
	set(value):
		score = value
		$Content/Text.text = TEMPLATE.format(score)

func _ready():
	$Content/Sprite.texture = Constants.sprites[PLAYER_ID]
