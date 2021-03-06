extends Node

const VERSION = "0.1"
const RELEASE_MODE = false

const FORCE_MAX_PLAYERS = false and !RELEASE_MODE
const SHOW_FPS = true and !RELEASE_MODE

# Game Settings
const NUM_PHASES = 3
const DRONE_LIFETIME = NUM_PHASES
const PHASE_DURATION = 25
const TURN_BASED = true

# Fixed settings
const START_HEALTH = 100
const BULLET_DAMAGE = 25
const SHOT_INTERVAL : float = 0.4

enum RecType {Movement, Shoot}
enum RecMode {Recording, Rewinding, Playing}

const colors = [Color(1.0, 0.0, 0.0, 1.0),
		  Color(0.0, 1.0, 0.0, 1.0),
		  Color(1.0, 1.0, 0.0, 1.0),
		  Color(0.0, 1.0, 1.0, 1.0)]
		
func get_colour_from_side(side):
	if side == 0:
		return "RED"
	elif side == 1:
		return "GREEN"
	elif side == 2:
		return "YELLOW"
	elif side == 3:
		return "MAGENTA"
	else:
		return "UNKNOWN"
		
var player_nums = []

var rnd : RandomNumberGenerator

func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.randomize()
	pass
	
