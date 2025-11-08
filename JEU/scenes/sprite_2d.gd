extends Sprite2D

# Ce script va automatiquement changer la frame selon la progression

func _ready():
	# S'assurer qu'on a bien 8 frames (0 à 7)
	if hframes == 0:
		hframes = 8  # 8 frames horizontales
	frame = 0  # Commencer à vide

func update_progress(current: int, target: int) -> void:
	# Calculer le pourcentage de progression
	var progress_ratio = float(current) / float(target)
	
	# Convertir en index de frame (0 à 7)
	var frame_index = int(progress_ratio * 7.0)
	
	# Limiter entre 0 et 7
	frame = clamp(frame_index, 0, 7)
	
	print("Progression: %d/%d = %.2f%% -> Frame %d" % [current, target, progress_ratio * 100, frame])
