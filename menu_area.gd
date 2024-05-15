extends ColorRect

## Each button calls the _on_button_pressed function with the appropriate difficulty (1-3)
# Initially I was thinking of having a "You will never win!" button, with predictive movement,
# (the CPU would calculate the position once you hit the ball and would go there), 
# but then you would INDEED never win :/
#
func _on_button_pressed(difficulty: int) -> void:
	Referee.choose_difficulty(difficulty)	
	Referee.play_start_sound()
	get_tree().change_scene_to_file("res://RGCong_play.tscn")

## When Ready: If a previous match has happened, show the winner!
#
func _ready():
	if Referee.delta_score == 0:
		return
	if Referee.delta_score > 0:
		%label_result.self_modulate = Color.GREEN
		%label_result.text = "You WON!"
	else:
		%label_result.self_modulate = Color.RED
		%label_result.text = "You LOST!"
