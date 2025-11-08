extends Camera2D

@export var target: Node2D  # Assignez votre Car ici dans l'inspecteur
@export var smoothing_speed: float = 5.0

func _process(delta: float) -> void:
	if target:
		# Suivre la position du joueur avec lissage
		global_position = global_position.lerp(target.global_position, smoothing_speed * delta)
		
		# Garder la rotation à 0 (pas de rotation)
		rotation = 0
