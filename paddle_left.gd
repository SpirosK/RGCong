## This is the Player-Controlled paddle
#
extends Node2D

const SPEED = 350  #Slower than the CPU paddle.

## Constructor: position it at center of the left side
#
func _init():
	position.x = 6
	position.y = 299

## Each tick: moves according to player input
#
func _physics_process(delta):
	if Input.is_action_pressed("p1_up"):
		position.y -= SPEED * delta
	if Input.is_action_pressed("p1_down"):
		position.y += SPEED * delta
	
	# Clamp the position to stay within the playing area
	position.y = clamp (position.y, 0, %playing_area.size.y - %left_paddle_rect.size.y )
