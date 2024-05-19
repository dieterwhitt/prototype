# apr 26 2024
# level manager - manages levels and player

extends Node

'''
PLEASE READ!!!
level_manager.gd is responsible for controlling the changing of levels and 
managing the player.
By copying the level_template scene, you'll be able to create levels,
and this file controls loading & switching between them

as of may 6 2024:
level_manager:
	- loads levels
	- moves the player across levels when they exit the screen
	- spawns the player in on intial load

level_manager DOES NOT YET:
	- handle player powerup scenes
	- save checkpoints and respawn player on death

(the unadded features above will be necessary but I 
haven't implemented them yet)

If you have any questions dm me on discord.
- dieter whittingham
'''

# starting the system, need to fix it to make it better
# good start though

# loaded scenes (deleted on checkpoint)
# path (string) : node
# keep all the loaded levels in here so that we aren't loading things twice
var loaded = {}
# current level path
@onready var curr_path : String = "res://world/levels/level_02.tscn"
# current scene
@onready var current : Node = \
	load(curr_path).instantiate()
# player
@onready var player : Node = \
	preload("res://players/player_reworked/player_reworked.tscn").instantiate()

# number of invincibility frames on scene change
var invince_frames = 1
var invince_timer = 0

func _ready():
	# read save file and adjust current, checkpoint
	start_current_level()
	spawn_player_default()

# starts the current level by adding it to the tree and loading its
# adjacent levels. does NOT spawn player
func start_current_level():
	if curr_path not in loaded:
		loaded.merge({curr_path : current})
	# now add current to tree
	add_child(current)
	# now we want to load all adjacent levels (smooth transitions)
	for border in current.adjacent:
		# border: top, bottom, left, right
		var adj_path : String = current.adjacent[border]
		if adj_path != "" and adj_path not in loaded:
			print("attempting to load " + adj_path)
			# if path was given and hasn't been loaded
			var packed_lvl : PackedScene = load(adj_path)
			if packed_lvl:
				loaded.merge({adj_path : packed_lvl.instantiate()})
				print("level loaded")
			else:
				print("level not found")

# spawns the player in the default spawnpoint
func spawn_player_default():
	var spawnpoint = current.get_node("Spawn").position
	player.position = spawnpoint
	invince_timer = invince_frames
	add_child(player)

func _physics_process(delta):
	update_invincibility()
	check_borders()

func update_invincibility():
	if invince_timer > 0:
		invince_timer -= 1
		print("i frame")
	else:
		player.set_collision_layer_value(2, true)
		player.set_collision_mask_value(1, true)

# check if the player is out of bounds
# for now we are limited to single screen levels
func check_borders():
	var posn = player.position
	# you want to keep the position in the dimension that remains unchanged
	# also need to fix this kinda shitty code
	if posn.y < current.top_y:
		# over top border
		if current.adjacent["top"] in loaded:
			# string key exists in loaded dict
			var top_lvl = loaded[current.adjacent["top"]]
			enter_border(top_lvl, 
					Vector2(posn.x, top_lvl.bottom_y))
	elif posn.y > current.bottom_y:
		# below bottom border
		if current.adjacent["bottom"] in loaded:
			var btm_lvl = loaded[current.adjacent["bottom"]]
			enter_border(btm_lvl, 
					Vector2(posn.x, btm_lvl.top_y))
	elif posn.x < current.left_x:
		# left of left border
		if current.adjacent["left"] in loaded:
			var lft_lvl = loaded[current.adjacent["left"]]
			enter_border(lft_lvl, 
					Vector2(lft_lvl.right_x, posn.y))
	elif posn.x > current.right_x:
		# right of right border
		if current.adjacent["right"] in loaded:
			var right_lvl = loaded[current.adjacent["right"]]
			enter_border(right_lvl, 
					Vector2(right_lvl.left_x, posn.y))
	

# function for entering a border
func enter_border(level : Node, posn : Vector2):
	print("crossing level border")
	remove_child(current)
	# move player
	player.position = posn
	
	# need to disable collision layer (invincibility frame on scene change)
	# this also avoids bugs with 1-frame misalignment, so 
	# you don't die to a spike on the other side when you change levels
	# also MAKE SURE TO EXTEND LEVELs BY 1 TILE AT EDGES TO PREVENT CLIPPING
	# OUT OF THE WORLD!
	player.set_collision_layer_value(2, false)
	player.set_collision_mask_value(1, false)
	
	invince_timer = invince_frames
	current = level
	start_current_level()
	print("adding player at %v" % posn)
	
	
	

