## This is the CPU-Controlled paddle
#
extends Node2D

const BASE_SPEED = 400
var random = RandomNumberGenerator.new()

## Initial position
#
func _init():
	position.x = 1262
	position.y = 299

## Returns the middle point of the racket (used to move it to ball)
#
func get_middle_point_y() -> int:
	return int(position.y +(%right_paddle_rect.get_size().y / 2))

# "A.I." always tries to hit the paddle at its center.
# However, how it will actually do it depends on the difficulty: 
# The harder it is the most certain it is to pick the right action (plus it's a bit faster)
#
func _physics_process(delta):
	var ball_middle_point_y = %ball.get_middle_point_y()
	var our_middle_point_y = get_middle_point_y()
	var speed = (1 + Referee.extra_speed_modifier) * BASE_SPEED

	#if a random number is less than the difficulty, it will go the right way
	#Otherwise it will stay put for this frame
	if random.randf_range(0,1) < Referee.get_difficulty():
		if ball_middle_point_y <= our_middle_point_y:
			position.y -= speed * delta
		else:
			position.y += speed * delta
	
	# Clamp the position to stay within the playing area
	position.y = clamp(position.y, 0, %playing_area.size.y - %right_paddle_rect.size.y )
