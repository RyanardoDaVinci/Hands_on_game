extends Node

var active_character = null

var position_theseus
var position_minotaur

var theseus_moving = false
var minotaur_moving = false

var theseus_located_positions = []
var minotaur_located_positions = []

var shortest_goal_distance = -1

var in_swap = false

func reset():
	active_character = null
	theseus_moving = false
	minotaur_moving = false
	theseus_located_positions = []
	minotaur_located_positions = []
	shortest_goal_distance = -1
	in_swap = false
