extends CanvasLayer

# Glissez-déposez les nodes depuis l'arbre de scène dans l'inspecteur
@export var label: Label
@export var jauge: Sprite2D
@export var fleche: Sprite2D


func update_display(current_kills: int, target_kills: int, current_wave: int, time_left: float, time_ratio: float) -> void:
	
	# Mettre à jour le texte
	if label:
		label.text = "Roberts tués: %d / %d\nVague: %d\nTemps restant: %.1fs" % [
			current_kills,
			target_kills,
			current_wave,
			time_left
		]
	else:
		print("❌ Label introuvable!")
	
	# Mettre à jour la jauge
	if jauge:
		if jauge.has_method("update_progress"):
			jauge.update_progress(current_kills, target_kills)
		else:
			print("❌ La jauge n'a pas de méthode update_progress!")
	else:
		print("❌ Jauge introuvable!")
	
	# Mettre à jour l'aiguille
	if fleche:
		if fleche.has_method("update_from_ratio"):
			fleche.update_from_ratio(time_ratio)
		else:
			print("❌ La flèche n'a pas de méthode update_from_ratio!")
	else:
		print("❌ Flèche introuvable!")

func show_game_over() -> void:
	if label:
		label.text += "\n💀 Partie perdue!"
