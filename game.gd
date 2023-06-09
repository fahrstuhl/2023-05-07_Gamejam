extends Node2D

signal checkpoint_id_changed

const TILE_SIZE := 16

var PLAYER = preload("res://player.tscn")
var STATUS = preload("res://status.tscn")
var ROCKET = preload("res://rocket.tscn")
var EXPLOSION = preload("res://explosion.tscn")

var scores = {}

func _ready():
	print("Joypads: ", Input.get_connected_joypads())
	spawn_players()
	update_scores()
	
func spawn_players():
	var spawnpoints = $Level/Spawns.get_children()
	for ID in Input.get_connected_joypads():
		var player = PLAYER.instantiate()
		player.PLAYER_ID = ID
		player.global_position = spawnpoints[player.PLAYER_ID].global_position
		var status = STATUS.instantiate()
		status.PLAYER_ID = ID
		player.connect("spawn_rocket", spawn_rocket)
		scores[player.PLAYER_ID] = {"kills": 0, "deaths": 0}
		$Level/Players.add_child(player)
		$Interface/PlayerStatus.add_child(status)

func spawn_rockets():
	spawn_rocket(Vector2(200, 200), 0, 0)
	spawn_rocket(Vector2(250, 100), 3*PI/2, 0)

func spawn_rocket(location, direction, id):
	var rocket := ROCKET.instantiate()
	rocket.global_position = location
	rocket.global_rotation = direction
	rocket.PLAYER_ID = id
	rocket.connect("spawn_explosion", spawn_explosion)
	$Level/Rockets.add_child(rocket)

func spawn_explosion(location, id):
	print("spawning explosion at {0} by player {1}".format([location, id]))
	var explosion := EXPLOSION.instantiate()
	explosion.global_position = location
	explosion.PLAYER_ID = id
	explosion.connect("hit_player_by", hit_player_by)
	explosion.connect("hit_rocket", hit_rocket)
	$Level/Explosions.add_child(explosion)

func hit_player_by(hit_id, by_id):
	print("Player {0} hit by player {1}".format([hit_id, by_id]))
	scores[hit_id]["deaths"] += 1
	if hit_id != by_id:
		scores[by_id]["kills"] += 1
	Input.start_joy_vibration(hit_id, 0, 0.5, 0.3)
	update_scores()

func update_scores():
	var ids = []
	for player in $Level/Players.get_children():
		ids.append(player.PLAYER_ID)
	for score in $Interface/PlayerStatus.get_children():
		if score.PLAYER_ID in ids:
			score.score = scores[score.PLAYER_ID]

func hit_rocket(id, rocket: Rocket):
	print("explosion by player {0} hit rocket by player {1}".format([id, rocket.PLAYER_ID]))
	rocket.explode()

func _input(event):
	if OS.is_debug_build() and event.is_action("ui_toggle_collision_shapes") and event.pressed:
		toggle_collision_shape_visibility()

func toggle_collision_shape_visibility() -> void:
	var tree := get_tree()
	tree.debug_collisions_hint = not tree.debug_collisions_hint

	# Traverse tree to call queue_redraw on instances of
	# CollisionShape2D and CollisionPolygon2D.
	var node_stack: Array[Node] = [tree.get_root()]
	while not node_stack.is_empty():
		var node: Node = node_stack.pop_back()
		if is_instance_valid(node):
			if node is CollisionShape2D or node is CollisionPolygon2D:
				node.queue_redraw()
			node_stack.append_array(node.get_children())
