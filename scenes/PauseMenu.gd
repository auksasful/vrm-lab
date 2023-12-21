extends Control

@onready var main = $"../"


func _on_resume_pressed():
	$ButtonClickStreamPlayer.play()
	main.pauseMenu()
	
func _on_back_to_main_menu_pressed():
	$ButtonClickStreamPlayer.play()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	
