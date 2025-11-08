extends Node2D

@export var enemy_scene: PackedScene  # Glissez votre scène Enemy ici
@export var spawn_interval: float = 2.0  # Temps entre chaque spawn
@export var spawn_margin: float = 50.0  # Distance en dehors de l'écran

var spawn_timer: float = 0.0

func _ready():
	# Optionnel : spawn un ennemi au démarrage
	spawn_enemy()

func _process(delta: float) -> void:
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_enemy()

func spawn_enemy() -> void:
	if not enemy_scene:
		push_error("Aucune scène d'ennemi assignée!")
		return
	
	var enemy = enemy_scene.instantiate()
	
	# Obtenir les dimensions de l'écran
	var viewport_rect = get_viewport_rect()
	var screen_size = viewport_rect.size
	
	# Choisir un côté aléatoire (0=haut, 1=droite, 2=bas, 3=gauche)
	var side = randi() % 4
	var spawn_pos = Vector2.ZERO
	
	match side:
		0:  # Haut
			spawn_pos = Vector2(
				randf_range(0, screen_size.x),
				-spawn_margin
			)
		1:  # Droite
			spawn_pos = Vector2(
				screen_size.x + spawn_margin,
				randf_range(0, screen_size.y)
			)
		2:  # Bas
			spawn_pos = Vector2(
				randf_range(0, screen_size.x),
				screen_size.y + spawn_margin
			)
		3:  # Gauche
			spawn_pos = Vector2(
				-spawn_margin,
				randf_range(0, screen_size.y)
			)
	
	enemy.global_position = spawn_pos
	get_parent().add_child(enemy)
	
	print("Ennemi spawné à: ", spawn_pos)
