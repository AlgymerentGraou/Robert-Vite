extends Control

@onready var credit = $credit

func _on_start_bnt_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_cutscene_bnt_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/intro_cinématique.tscn")


func _on_credit_bnt_pressed() -> void:
	credit.show()


func _on_quit_bnt_pressed() -> void:
	get_tree().quit()


func _on_credit_close_requested() -> void:
	credit.hide()
