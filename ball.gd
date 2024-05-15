extends Node2D

var random = RandomNumberGenerator.new()
var velocity = Vector2.ZERO  # Initial velocity of the ball
const WHITE_BORDER_WIDTH_Y = 16
const BALL_DIAMETER = 32  #we already know that

## Resets the ball position to the center of the playing area
#
func reset_ball_position() -> void:
	position = Vector2(640, 375)
	init_ball_velocity()

## Initial Ball velocity:
#  X = 300 - 600
#  Y = 0 - 600 (always <= X) 
#  left/right and up/down done randomly as well
#
func init_ball_velocity() -> void:
	random.randomize()
	var left_or_right = random.randi_range(0,1)
	if left_or_right == 0:
		left_or_right = -1
	var up_or_down = random.randi_range(0,1)
	if up_or_down == 0:
		up_or_down = -1
	var velocityX = 300 + 100 * random.randf_range(0, 3)
	var velocityY = velocityX - 100 * random.randf_range(0, 3)
	velocity = Vector2(velocityX * left_or_right, velocityY * up_or_down)


## Called when first created/started
# 1. Resets the Ball Position
#  
func _init():
	reset_ball_position()

## Calculates the y speed increase or not, depending on where the ball hit the paddle
# It increases most at edges & slows down in the center area, so that CPU can counteract the speedup
# +20 up/down%: 0-20/80-100% || +10% up/down: 20-40/60-80% || same: 40-60% || SLOW-DOWN: 48-52%
#  
func y_speed_increase (position_y: int, paddle_position_y: int, paddle_size_y: int) -> float:
	var delta_y_percent = float(position_y - paddle_position_y) / paddle_size_y
	#print ("DYP: " + str(delta_y_percent))
	if delta_y_percent < 0.2 or delta_y_percent > 0.8:
		return 1.22
	if delta_y_percent < 0.4 or delta_y_percent > 0.6:
		return 1.11
	if delta_y_percent < 0.48 or delta_y_percent > 0.52:
		return 1.0
	return 0.9

## Returns the ball's middle point in y-axis
#  it's also called from the CPU paddle
#
func get_middle_point_y() -> int:
	var ball_radius = BALL_DIAMETER / 2
	return (position.y + ball_radius)

## What happens at every tick:
#  1. We check for collisions with up/down walls
#  2. We check for scoring events
#  3. We check for collisions with paddles
#  
func _physics_process(delta):
	var ball_radius = BALL_DIAMETER / 2
	%Score.text = Referee.get_score()

	### Move the ball based on its velocity
	position += velocity * delta

	##########################################
	# Check for collisions with up/down walls
	##########################################
	var ball_down_side = position.y + BALL_DIAMETER
	if (position.y < WHITE_BORDER_WIDTH_Y and velocity.y < 0) or ( ball_down_side > %playing_area.size.y + WHITE_BORDER_WIDTH_Y and velocity.y > 0):
		velocity.y *= -1

	###########################
	# Check for scoring events
	###########################
	var ball_right_side = position.x + ball_radius
	if ball_right_side < 0:
		Referee.player2_scored()
		reset_ball_position()
		return
	elif position.x > %playing_area.size.x:
		Referee.player1_scored()
		reset_ball_position()
		return

	###################################
	# Check for collisions with paddles
	###################################
	var ball_down_y = position.y + BALL_DIAMETER
	var ball_up_y = position.y
	var ball_left_side = position.x
	var right_padl_down_y = %right_paddle.position.y + %right_paddle_rect.size.y
	var left_padl_down_y = %left_paddle.position.y + %left_paddle_rect.size.y
	var left_padl_right_side = %left_paddle.position.x + %left_paddle_rect.size.x
	#Ball Middle is NOT ideal, but it will have to do for the purposes of this
	
	#HITS LEFT/RIGHT WHEN:
	# 1. BAll has touched/passed paddle's their facing (left/right) side
	# 2. Ball's sprite is anywhere between the up and down limits of paddle
	# 3. It actually goes towards their goal (to avoid trapping it in the paddle)
	#
	# X-Speed increases with each successful hit at a steady pace of 5%!
	# For Y-speed check function 'y_speed_increase' function comments
	#
	if ball_right_side >= %right_paddle.position.x and ball_down_y >= %right_paddle.position.y and ball_up_y <= right_padl_down_y and velocity.x > 0:
		velocity.y *= y_speed_increase (position.y, %right_paddle.position.y, %right_paddle_rect.size.y)
		velocity.x *= -Referee.X_SPEED_MULTIPLIER
		Referee.play_hit_sound()
	elif ball_left_side <= left_padl_right_side and ball_down_y >= %left_paddle.position.y and ball_up_y <= left_padl_down_y and velocity.x < 0:
		velocity.y *= y_speed_increase (position.y, %left_paddle.position.y, %left_paddle_rect.size.y)
		velocity.x *= -Referee.X_SPEED_MULTIPLIER
		Referee.play_hit_sound()
