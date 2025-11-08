extends CanvasLayer

# Glissez-déposez les nodes depuis l'arbre de scène dans l'inspecteur
@export var label: Label
@export var jauge: Sprite2D
@export var fleche: Sprite2D

func _ready():
	print("[Cadran] _ready() appelé")
	print(" - Label trouvé :", label != null)
	print(" - Jauge trouvée :", jauge != null)
	print(" - Flèche trouvée :", fleche != null)

func update_display(current_kills: int, target_kills: int, current_wave: int, time_left: float, time_ratio: float) -> void:
	print("[Cadran] update_display appelé - kills: %d/%d, ratio: %.2f" % [current_kills, target_kills, time_ratio])
	
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
			print("🔄 Appel de jauge.update_progress(%d, %d)" % [current_kills, target_kills])
			jauge.update_progress(current_kills, target_kills)
		else:
			print("❌ La jauge n'a pas de méthode update_progress!")
	else:
		print("❌ Jauge introuvable!")
	
	# Mettre à jour l'aiguille
	if fleche:
		if fleche.has_method("update_from_ratio"):
			print("🔄 Appel de fleche.update_from_ratio(%.2f)" % time_ratio)
			fleche.update_from_ratio(time_ratio)
		else:
			print("❌ La flèche n'a pas de méthode update_from_ratio!")
	else:
		print("❌ Flèche introuvable!")

func show_game_over() -> void:
	if label:
		label.text += "\n💀 Partie perdue!"
