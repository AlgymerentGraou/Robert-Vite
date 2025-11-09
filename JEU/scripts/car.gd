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
	
	car_sil.rotation = -rotation
	# Mettre à jour la frame selon la direction
	car_sil.frame = _current_direction

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
			max_speed += 50
			print("⚡ [BONUS-VITESSE] Vitesse max : ", old_speed, " → ", max_speed, " (+50)")
		
		"Taille":
			if car_sprite:
				var old_scale = car_sprite.scale
				var new_scale = car_sprite.scale * 1.1
				car_sprite.scale = new_scale
				print("📏 [BONUS-TAILLE] Échelle : ", old_scale, " → ", new_scale, " (+10%)")
		
			if car_sil:
				var old_scale_sil = car_sil.scale
				var new_scale_sil = car_sil.scale * 1.1
				car_sil.scale = new_scale_sil
				print("📏 [BONUS-TAILLE] Échelle : ", old_scale_sil, " → ", new_scale_sil, " (+10%)")
		
		"Maniabilité":
			var old_accel = acceleration_speed
			acceleration_speed += 100
			print("🎯 [BONUS-MANIABILITÉ] Accélération : ", old_accel, " → ", acceleration_speed, " (+100)")
			
