## The Singleton that handles the game commons: Difficulty, Sounds, Score
#
extends Node

var player1_score = 0
var player2_score = 0
var delta_score = 0      #The difference of the two scores, used to know the winner on menu screen
const MIN_DIFFICULTY = 1 #Min and max in consts in order to be extensible
const MAX_DIFFICULTY = 3
const WINNING_SCORE = 11 #Whoever reaches this number first is the winner!

const DIFFICULTY_MODIFIER = 0.33
const EXTRA_SPEED_MODIFIER = 0.25
const X_SPEED_MULTIPLIER = 1.05      # Speed multiplier for increasing ball speed over hits
var difficulty = DIFFICULTY_MODIFIER #Easy at boot
var extra_speed_modifier = 0.0       #Easy at boot

## Audio related block
#
var sfx_hit = preload("res://sfx/pong_hit.mp3")
var sfx_score = preload("res://sfx/pong_score.mp3")
var sfx_start = preload("res://sfx/pong_start.mp3")
var audioPlayer = AudioStreamPlayer.new()

## Constructor: Adds the audio player in
#
func _init():
	add_child(audioPlayer)

## When the game ends, store the difference (to know the winner), reset score, get back to menu
#
func end_game() -> void:
	delta_score = player1_score - player2_score
	reset_score()
	get_tree().change_scene_to_file("res://RGCong_menu.tscn")

## Resetting the difficulty resets the score as well
#
func reset_to_difficulty(level: int) -> void:
	reset_score()
	choose_difficulty(level)

## Clamping the level and resulting value to make sure invalid numbers will not affect it
#
func choose_difficulty(level: int) -> void:
	level = clampi (level, MIN_DIFFICULTY, MAX_DIFFICULTY)
	difficulty = clamp(level * DIFFICULTY_MODIFIER, 0.0, 1.0)
	extra_speed_modifier = (level-1) * EXTRA_SPEED_MODIFIER
	#print ("Difficulty = " + str(difficulty))
	#print ("ESM = " + str(extra_speed_modifier))

## Getter: Difficulty
#
func get_difficulty() -> float:
	return difficulty

## Both players to Zero
#
func reset_score() -> void:
	player1_score = 0
	player2_score = 0

## Getter: Score (Difficulty)
#
func get_score() -> String:
	return str(player1_score) + " - " + str(player2_score)

## Plays the starting game sound
#
func play_start_sound() -> void:
	audioPlayer.stream = sfx_start
	audioPlayer.play()
	
## Plays the hitting ball sound
#
func play_hit_sound() -> void:
	audioPlayer.stream = sfx_hit
	audioPlayer.play()

## Plays the scoring goal sound
#
func play_score_sound() -> void:
	audioPlayer.stream = sfx_score
	audioPlayer.play()

## When player scores, his/her score goes up and sound is played
#
func player1_scored() -> void:
	play_score_sound()
	player1_score += 1
	if player1_score == WINNING_SCORE:
		end_game()

## When CPU scores, its score goes up and sound is played
#
func player2_scored() -> void:
	play_score_sound()
	player2_score += 1
	if player2_score == WINNING_SCORE:
		end_game()
