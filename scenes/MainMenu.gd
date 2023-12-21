extends Control




func _on_button_pressed():
	$ButtonClickStreamPlayer.play()
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")


func _on_button_2_pressed():
	$ButtonClickStreamPlayer.play()
	get_tree().quit()
