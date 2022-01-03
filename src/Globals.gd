extends Node

const VERSION = "0.1"
const RELEASE_MODE = false

const FORCE_MAX_PLAYERS = false and !RELEASE_MODE
const SHOW_FPS = true and !RELEASE_MODE

# Game Settings
const NUM_PHASES = 3
const PHASE_DURATION = 10 # 25 todo
const TURN_BASED = false

# Fixed settings
const SHOT_INTERVAL : float = 0.5

enum RecType {Movement, Shoot}
enum RecMode {Recording, Rewinding, Playing}

const colors = [Color(1.0, 0.0, 0.0, 1.0),
		  Color(0.0, 1.0, 0.0, 1.0),
		  Color(1.0, 1.0, 0.0, 1.0),
		  Color(0.0, 1.0, 1.0, 1.0)]

var player_nums = []

var rnd : RandomNumberGenerator

func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.randomize()
	pass
	
