extends Node2D

@export var enemy_scene: PackedScene  # Glissez votre scène Enemy ici
@export var spawn_interval: float = 2.0  # Temps entre chaque spawn
@export var spawn_margin: float = 100.0  # Distance en dehors de l'écran visible

var spawn_timer: float = 0.0

func _process(delta: float) -> void:
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_enemy()

func spawn_enemy() -> void:
	if not enemy_scene:
		push_error("❌ [SPAWNER] Aucune scène Enemy assignée!")
		return
	
	var camera = get_viewport().get_camera_2d()
	if not camera:
		push_error("❌ [SPAWNER] Aucune caméra trouvée!")
		return
	
	# Récupérer la taille visible de l'écran
	var viewport_size = get_viewport_rect().size
	var camera_pos = camera.global_position
	var zoom = camera.zoom
	
	# Calculer les limites visibles (en tenant compte du zoom)
	var half_width = (viewport_size.x / zoom.x) / 2.0
	var half_height = (viewport_size.y / zoom.y) / 2.0
	
	# Choisir un côté aléatoire (0=haut, 1=droite, 2=bas, 3=gauche)
	var side = randi() % 4
	var spawn_pos = Vector2.ZERO
	
	match side:
		0:  # Haut
			spawn_pos.x = camera_pos.x + randf_range(-half_width, half_width)
			spawn_pos.y = camera_pos.y - half_height - spawn_margin
		1:  # Droite
			spawn_pos.x = camera_pos.x + half_width + spawn_margin
			spawn_pos.y = camera_pos.y + randf_range(-half_height, half_height)
		2:  # Bas
			spawn_pos.x = camera_pos.x + randf_range(-half_width, half_width)
			spawn_pos.y = camera_pos.y + half_height + spawn_margin
		3:  # Gauche
			spawn_pos.x = camera_pos.x - half_width - spawn_margin
			spawn_pos.y = camera_pos.y + randf_range(-half_height, half_height)
	
	# Créer l'ennemi
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	get_parent().add_child(enemy)
