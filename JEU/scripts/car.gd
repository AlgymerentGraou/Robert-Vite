class_name Player extends CharacterBody2D

# Paramètres de la voiture
@export_group("Car Settings")
@export var wheel_base: float = 70  # Distance entre les roues avant et arrière
@export var steering_angle: float = 25  # Angle de braquage en degrés
@export var engine_power: float = 1200  # Force d'accélération
@export var braking: float = -250  # Force de freinage
@export var max_speed_reverse: float = 250  # Vitesse max en marche arrière

# Friction et traînée
@export_group("Friction and Drag")
@export var friction: float = -0.4
@export var drag: float = -0.0005

# Drift/Glisse
@export_group("Drift Related")
@export var slip_speed: float = 250
@export var traction_fast: float = 0.05
@export var traction_slow: float = 0.8

# Sprite avec 8 directions
@export_group("Visual")
@export var car_sprite: Sprite2D  # Glissez votre Sprite2D ici

# Variables internes
var _acceleration: Vector2 = Vector2.ZERO
var _steer_angle: float
var _current_heading: float = 0.0  # Direction actuelle de la voiture

var score: int = 0


func _ready():
	# Configurer le sprite s'il existe
	if car_sprite:
		car_sprite.hframes = 8  # 8 frames horizontales
		car_sprite.frame = 0


func _physics_process(delta: float) -> void:
	_acceleration = Vector2.ZERO
	get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += _acceleration * delta
	move_and_slide()


func get_input():
	var turn = 0
	if Input.is_action_pressed("RIGHT"):
		turn += 1
	if Input.is_action_pressed("LEFT"):
		turn -= 1
	_steer_angle = turn * deg_to_rad(steering_angle)
	
	if Input.is_action_pressed("UP"):
		_acceleration = transform.x * engine_power
	if Input.is_action_pressed("DOWN"):
		_acceleration = transform.x * braking


func apply_friction():
	# Arrêt complet à très basse vitesse
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	
	# Friction plus forte à basse vitesse
	if velocity.length() < 100:
		friction_force *= 3
	
	_acceleration += drag_force + friction_force


func calculate_steering(delta: float):
	# Position des roues arrière et avant
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	
	# Déplacement des roues
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(_steer_angle) * delta
	
	# Nouvelle direction
	var new_heading = (front_wheel - rear_wheel).normalized()
	
	# Sélection de la traction selon la vitesse
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	
	# Vérifier si on avance ou recule (dot product)
	var d = new_heading.dot(velocity.normalized())
	
	if d > 0:
		# Avancer avec glisse progressive (lerp pour le drift)
		velocity = velocity.lerp(new_heading * velocity.length(), traction)
	if d < 0:
		# Marche arrière
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	
	# Sauvegarder la direction pour le sprite et la rotation invisible du body
	_current_heading = new_heading.angle()
	rotation = _current_heading  # Le body tourne (pour transform.x)
	
	# Mettre à jour le sprite visuellement
	if car_sprite:
		update_sprite_direction(_current_heading)


func update_sprite_direction(angle_rad: float):
	if not car_sprite:
		return
	
	# Convertir la rotation en angle (0 à 360 degrés)
	var angle_deg = rad_to_deg(angle_rad)
	
	# Normaliser l'angle entre 0 et 360
	if angle_deg < 0:
		angle_deg += 360
	
	# Diviser en 8 directions (45 degrés chacune)
	# Frame 0 = Droite (0°)
	# Frame 1 = Bas-Droite (45°)
	# Frame 2 = Bas (90°)
	# Frame 3 = Bas-Gauche (135°)
	# Frame 4 = Gauche (180°)
	# Frame 5 = Haut-Gauche (225°)
	# Frame 6 = Haut (270°)
	# Frame 7 = Haut-Droite (315°)
	
	var frame_index = int((angle_deg + 22.5) / 45.0) % 8
	car_sprite.frame = frame_index
	
	# Annuler la rotation du sprite pour qu'il reste droit
	car_sprite.rotation = -rotation


func add_score(amount:int) -> void:
	score += amount
	print(score)
