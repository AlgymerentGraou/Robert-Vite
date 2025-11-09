class_name Car extends CharacterBody2D

# Paramètres de la voiture
@export_group("Car Settings")
@export var acceleration_speed: float = 800.0
@export var max_speed: float = 800.0
@export var friction: float = 600.0

# Sprite avec 8 directions
@export_group("Visual")
@export var car_sprite: Sprite2D
@export var car_sil: Sprite2D
@export var collision_shape: CollisionShape2D  # Pour la rotation

# Traînées de feu
@export_group("Fire Trails")
@export var fire_trail_front_left: CPUParticles2D
@export var fire_trail_front_right: CPUParticles2D
@export var fire_trail_rear_left: CPUParticles2D
@export var fire_trail_rear_right: CPUParticles2D
@export var speed_threshold_for_fire: float = 400.0  # Vitesse minimum pour le feu

# Positions relatives des roues par rapport au centre de la voiture
@export_group("Wheel Positions")
@export var front_left_offset: Vector2 = Vector2(-15, -25)
@export var front_right_offset: Vector2 = Vector2(15, -25)
@export var rear_left_offset: Vector2 = Vector2(-15, 25)
@export var rear_right_offset: Vector2 = Vector2(15, 25)

# Variables internes
var _current_direction: int = 0  # Index de la direction (0-7)
var score: int = 0

# 8 directions isométriques en degrés
const ISO_ANGLES: Array[float] = [0.0, 27.5, 90.0, 152.5, 180.0, 207.5, 270.0, 332.5]

# 📦 SYSTÈME DE BONUS
var bonus_inventory: Array[String] = []  # Liste des bonus obtenus

func _ready():
	if car_sprite:
		car_sprite.hframes = 8
		car_sprite.frame = 0
	# Initialiser à la direction droite (0°)
	_current_direction = 0
	update_rotation()

func _physics_process(delta: float) -> void:
	handle_input()
	apply_movement(delta)
	update_sprite()
	update_fire_trails()  # Gérer les traînées de feu
	move_and_slide()

func handle_input():
	var input_dir = Vector2.ZERO
	
	# Récupérer l'input
	if Input.is_action_pressed("RIGHT"):
		input_dir.x += 1
	if Input.is_action_pressed("LEFT"):
		input_dir.x -= 1
	if Input.is_action_pressed("DOWN"):
		input_dir.y += 1
	if Input.is_action_pressed("UP"):
		input_dir.y -= 1
	
	# Si on a un input, déterminer la direction iso la plus proche
	if input_dir.length() > 0:
		var input_angle = rad_to_deg(input_dir.angle())
		if input_angle < 0:
			input_angle += 360
		
		# Trouver la direction iso la plus proche
		_current_direction = get_closest_iso_direction(input_angle)
		update_rotation()

func get_closest_iso_direction(angle: float) -> int:
	var closest_index = 0
	var min_diff = 360.0
	
	for i in range(ISO_ANGLES.size()):
		var diff = abs(angle - ISO_ANGLES[i])
		# Gérer le wrap around (ex: 359° vs 0°)
		if diff > 180:
			diff = 360 - diff
		
		if diff < min_diff:
			min_diff = diff
			closest_index = i
	
	return closest_index

func update_rotation():
	# Mettre à jour la rotation du CharacterBody2D
	rotation = deg_to_rad(ISO_ANGLES[_current_direction])

func apply_movement(delta: float):
	# Accélérer dans la direction actuelle si on appuie sur une touche
	var is_moving = (Input.is_action_pressed("UP") or 
					 Input.is_action_pressed("DOWN") or 
					 Input.is_action_pressed("LEFT") or 
					 Input.is_action_pressed("RIGHT"))
	
	if is_moving:
		# Calculer la direction du mouvement
		var move_direction = Vector2.RIGHT.rotated(rotation)
		velocity += move_direction * acceleration_speed * delta
		
		# Limiter la vitesse max
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
	else:
		# Appliquer la friction
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func update_sprite():
	if not car_sprite:
		return
	
	# Annuler la rotation du body pour le sprite
	car_sprite.rotation = -rotation
	# Mettre à jour la frame selon la direction
	car_sprite.frame = _current_direction
	
	if car_sil:
		car_sil.rotation = -rotation
		# Mettre à jour la frame selon la direction
		car_sil.frame = _current_direction
	
	# Faire tourner le CollisionShape2D avec la voiture
	if collision_shape:
		collision_shape.rotation = 0  # Suit la rotation du parent (Car body)
	
	# Mettre à jour les positions des particules pour qu'elles suivent les roues
	update_wheel_positions()

func update_fire_trails() -> void:
	var current_speed = velocity.length()
	var should_emit = current_speed >= speed_threshold_for_fire
	
	# Activer/désactiver toutes les traînées selon la vitesse
	if fire_trail_front_left:
		fire_trail_front_left.emitting = should_emit
	
	if fire_trail_front_right:
		fire_trail_front_right.emitting = should_emit
	
	if fire_trail_rear_left:
		fire_trail_rear_left.emitting = should_emit
	
	if fire_trail_rear_right:
		fire_trail_rear_right.emitting = should_emit


func update_wheel_positions() -> void:
	# Mettre à jour les positions des particules pour suivre les roues
	# Les offsets tournent avec la voiture
	if fire_trail_front_left:
		fire_trail_front_left.position = front_left_offset.rotated(rotation)
		fire_trail_front_left.rotation = 0  # Suit la rotation du parent
	
	if fire_trail_front_right:
		fire_trail_front_right.position = front_right_offset.rotated(rotation)
		fire_trail_front_right.rotation = 0
	
	if fire_trail_rear_left:
		fire_trail_rear_left.position = rear_left_offset.rotated(rotation)
		fire_trail_rear_left.rotation = 0
	
	if fire_trail_rear_right:
		fire_trail_rear_right.position = rear_right_offset.rotated(rotation)
		fire_trail_rear_right.rotation = 0

func add_score(amount: int) -> void:
	score += amount

# 🎁 GESTION DES BONUS
func add_bonus(bonus_name: String) -> void:
	bonus_inventory.append(bonus_name)
	print("🎁 [BONUS] Nouveau bonus obtenu : ", bonus_name)
	apply_bonus_effect(bonus_name)
	print("📦 [BONUS] Inventaire complet : ", bonus_inventory)
	print("📊 [BONUS] Nombre total de bonus : ", bonus_inventory.size())

func apply_bonus_effect(bonus_name: String) -> void:
	match bonus_name:
		"Vitesse":
			var old_speed = max_speed
			max_speed += 100
			print("⚡ [BONUS-VITESSE MAX] Vitesse max : ", old_speed, " → ", max_speed, " (+100)")
		
		"Maniabilité":
			var old_accel = acceleration_speed
			acceleration_speed += 150
			print("🎯 [BONUS-ACCÉLÉRATION] Accélération : ", old_accel, " → ", acceleration_speed, " (+150)")
