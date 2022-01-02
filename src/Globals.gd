extends Node

const VERSION = "0.1"
const RELEASE_MODE = false

const USE_BOMBS = true and !RELEASE_MODE
const THIRD_PERSON_MODE = false and !RELEASE_MODE
const FORCE_MAX_PLAYERS = true and !RELEASE_MODE
const SHOW_FPS = true and !RELEASE_MODE

const PHASE_DURATION = 10 # 25 todo
const SHOT_INTERVAL = 1

enum RecType {Movement, Shoot}
enum RecMode {Recording, Rewinding, Playing}

const colors = [Color(1.0, 0.0, 0.0, 1.0),
		  Color(0.0, 1.0, 0.0, 1.0),
		  Color(1.0, 1.0, 0.0, 1.0),
		  Color(0.0, 1.0, 1.0, 1.0)]

var player_nums = []
#var recorders = []

var rnd : RandomNumberGenerator

func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.randomize()
	pass
	
