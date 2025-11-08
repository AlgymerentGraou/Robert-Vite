class_name Car extends CharacterBody2D

# Paramètres de la voiture
@export_group("Car Settings")
@export var wheel_base: float = 70
@export var steering_angle: float = 25
@export var engine_power: float = 1200
@export var braking: float = -250
@export var max_speed_reverse: float = 250

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
@export var car_sprite: Sprite2D

# Variables internes
var _acceleration: Vector2 = Vector2.ZERO
var _steer_angle: float
var _current_heading: float = 0.0
var score: int = 0

# 📦 SYSTÈME DE BONUS
var bonus_inventory: Array[String] = []  # Liste des bonus obtenus

func _ready():
	if car_sprite:
		car_sprite.hframes = 8
		car_sprite.frame = 0
	_current_heading = rotation

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
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	
	if velocity.length() < 100:
		friction_force *= 3
	
	_acceleration += drag_force + friction_force

func calculate_steering(delta: float):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(_steer_angle) * delta
	
	var new_heading = (front_wheel - rear_wheel).normalized()
	
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	
	var d = new_heading.dot(velocity.normalized())
	
	if d > 0:
		velocity = velocity.lerp(new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	
	_current_heading = new_heading.angle()
	rotation = _current_heading
	
	if car_sprite:
		car_sprite.rotation = -rotation
		update_sprite_direction(_current_heading)

func update_sprite_direction(angle_rad: float):
	if not car_sprite:
		return
	
	var angle_deg = rad_to_deg(angle_rad)
	
	if angle_deg < 0:
		angle_deg += 360
	
	var frame_index = int((angle_deg + 22.5) / 45.0) % 8
	car_sprite.frame = frame_index

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
			engine_power += 200
			print("⚡ Puissance moteur augmentée : ", engine_power)
		
		"Taille":
			if car_sprite:
				var new_scale = car_sprite.scale * 1.1
				car_sprite.scale = new_scale
				print("📏 Taille augmentée : ", new_scale)
		
		"Maniabilité":
			steering_angle += 3
			print("🎯 Maniabilité augmentée : ", steering_angle, "°")
