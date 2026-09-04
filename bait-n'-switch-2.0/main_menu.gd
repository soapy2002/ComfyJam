extends Control


func _on_start_game_pressed() -> void:
	print("Start Button Pressed")
	get_tree().change_scene_to_file("res://World.tscn")


func _on_options_pressed() -> void:
	print("Options Button Pressed")


func _on_quit_game_pressed() -> void:
	get_tree().quit()
