extends Control




func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main menu.tscn")
