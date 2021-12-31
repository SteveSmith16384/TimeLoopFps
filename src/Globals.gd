extends Node

const VERSION = "0.1"
const RELEASE_MODE = false

const USE_BOMBS = true and !RELEASE_MODE
const THIRD_PERSON_MODE = false and !RELEASE_MODE
const FORCE_MAX_PLAYERS = true and !RELEASE_MODE
const SHOW_FPS = true and !RELEASE_MODE

enum RecType {Movement, Shoot}

var player_nums = []
var recorders = []

var rnd : RandomNumberGenerator


func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.randomize()
	pass
	
