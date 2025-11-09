extends CharacterBody2D

@export_group("Settings")
@export var SPEED: float = 100.0
@export var enemy_sprite: AnimatedSprite2D

@export_group("Behavior")
@export var wander_speed: float = 50.0  # Vitesse de balade
@export var gather_radius: float = 150.0  # Distance pour se regrouper avec d'autres Roberts
@export var wander_change_interval: float = 2.0  # Changer de direction toutes les X secondes

var _is_dying: bool = false
var kill_value: int = 1

# Variables de Wander
var wander_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0

# Variables de Gather
var nearby_roberts: Array = []

func _ready():
	# Direction initiale aléatoire
	randomize_wander_direction()

func _physics_process(delta: float) -> void:
	if _is_dying:
		return
	
	# Mettre à jour le timer de wander
	wander_timer += delta
	if wander_timer >= wander_change_interval:
		wander_timer = 0.0
		randomize_wander_direction()
	
	# Trouver les Roberts à proximité pour se regrouper
	find_nearby_roberts()
	
	# Calculer la direction finale (wander + gather)
	var final_direction = calculate_movement_direction()
	
	# Appliquer le mouvement
	velocity = final_direction * wander_speed
	
	# Flip le sprite selon la direction
	if enemy_sprite and final_direction.x != 0:
		enemy_sprite.flip_h = final_direction.x < 0
	
	move_and_slide()

func randomize_wander_direction() -> void:
	# Direction aléatoire pour le wander
	var angle = randf() * TAU  # Angle aléatoire entre 0 et 2π
	wander_direction = Vector2(cos(angle), sin(angle))

func find_nearby_roberts() -> void:
	nearby_roberts.clear()
	
	# Trouver tous les ennemis dans le groupe
	var all_enemies = get_tree().get_nodes_in_group("Enemy")
	
	for enemy in all_enemies:
		if enemy == self:
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance < gather_radius:
			nearby_roberts.append(enemy)

func calculate_movement_direction() -> Vector2:
	var direction = wander_direction
	
	# Si des Roberts sont à proximité, se rapprocher d'eux (gather)
	if nearby_roberts.size() > 0:
		var gather_direction = Vector2.ZERO
		
		for robert in nearby_roberts:
			var dir_to_robert = global_position.direction_to(robert.global_position)
			gather_direction += dir_to_robert
		
		# Moyenne des directions vers les Roberts proches
		gather_direction = gather_direction.normalized()
		
		# Mélanger wander et gather (70% gather, 30% wander)
		direction = (gather_direction * 0.7 + wander_direction * 0.3).normalized()
	
	return direction

func _on_death_zone_body_entered(body: Node2D) -> void:
	if _is_dying:
		return
	
	if body.is_in_group("Player"):
		_is_dying = true
		
		# Screenshake
		var camera = get_viewport().get_camera_2d()
		if camera and camera.has_method("apply_shake"):
			camera.apply_shake(15.0)
		
		# Ajouter les kills
		var world = get_tree().current_scene
		if world and world.has_method("add_kill"):
			world.add_kill(kill_value)
			print("Kill ajouté! Valeur: ", kill_value)
		
		# Effets de mort
		if has_node("CPUParticles2D"):
			$CPUParticles2D.emitting = true
		
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.visible = false
		
		if has_node("CollisionShape2D"):
			$CollisionShape2D.disabled = true
		
		await get_tree().create_timer(1.1).timeout
		queue_free()

func set_kill_value(value: int) -> void:
	kill_value = value
