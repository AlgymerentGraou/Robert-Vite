extends CharacterBody2D

@export_group("Settings")
@export var SPEED: float = 100.0
@export var enemy_sprite: AnimatedSprite2D

@export_group("Behavior")
@export var wander_speed: float = 50.0  # Vitesse de balade
@export var gather_radius: float = 150.0  # Distance pour se regrouper
@export var merge_distance: float = 30.0  # Distance pour fusionner
@export var separation_distance: float = 40.0  # Distance minimum entre Roberts
@export var separation_strength: float = 0.5  # Force de séparation
@export var wander_change_interval: float = 2.0  # Changer de direction

var _is_dying: bool = false
var kill_value: int = 1

# Variables de Wander
var wander_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0

# Variables de Gather
var nearby_roberts: Array = []

func _ready():
	randomize_wander_direction()
	add_to_group("Enemy")

func _physics_process(delta: float) -> void:
	if _is_dying:
		return
	
	# Mettre à jour le timer de wander
	wander_timer += delta
	if wander_timer >= wander_change_interval:
		wander_timer = 0.0
		randomize_wander_direction()
	
	# Trouver les Roberts à proximité
	find_nearby_roberts()
	
	# Tenter de fusionner avec des Roberts proches
	attempt_merge()
	
	# Calculer la direction finale (wander + gather + separation)
	var final_direction = calculate_movement_direction()
	
	# Appliquer le mouvement
	velocity = final_direction * wander_speed
	
	# Flip le sprite selon la direction
	if enemy_sprite and final_direction.x != 0:
		enemy_sprite.flip_h = final_direction.x < 0
	
	move_and_slide()

func randomize_wander_direction() -> void:
	var angle = randf() * TAU
	wander_direction = Vector2(cos(angle), sin(angle))

func find_nearby_roberts() -> void:
	nearby_roberts.clear()
	
	var all_enemies = get_tree().get_nodes_in_group("Enemy")
	
	for enemy in all_enemies:
		if enemy == self or not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance < gather_radius:
			nearby_roberts.append(enemy)

func attempt_merge() -> void:
	if _is_dying:
		return
	
	for robert in nearby_roberts:
		if not is_instance_valid(robert) or robert._is_dying:
			continue
		
		var distance = global_position.distance_to(robert.global_position)
		
		# Si assez proche, fusionner
		if distance < merge_distance:
			merge_with(robert)
			return  # Une fusion à la fois

func merge_with(other: Node) -> void:
	if not is_instance_valid(other):
		return
	
	# Additionner les valeurs de kill
	var combined_value = kill_value + other.kill_value
	
	print("🔄 [MERGE] Fusion de Roberts : %d + %d = %d" % [kill_value, other.kill_value, combined_value])
	
	# Mettre à jour la valeur de ce Robert
	set_kill_value(combined_value)
	
	# Détruire l'autre Robert
	if other.has_method("destroy_silently"):
		other.destroy_silently()
	else:
		other.queue_free()

func calculate_movement_direction() -> Vector2:
	var direction = wander_direction
	var gather_direction = Vector2.ZERO
	var separation_direction = Vector2.ZERO
	
	# Gather : Se rapprocher des Roberts éloignés
	var gather_count = 0
	
	for robert in nearby_roberts:
		if not is_instance_valid(robert):
			continue
		
		var distance = global_position.distance_to(robert.global_position)
		var dir_to_robert = global_position.direction_to(robert.global_position)
		
		# Séparation : S'éloigner si trop proche
		if distance < separation_distance:
			separation_direction -= dir_to_robert  # Direction opposée
		# Gather : Se rapprocher si à distance moyenne
		elif distance < gather_radius:
			gather_direction += dir_to_robert
			gather_count += 1
	
	# Normaliser les directions
	if gather_count > 0:
		gather_direction = gather_direction.normalized()
	
	if separation_direction.length() > 0:
		separation_direction = separation_direction.normalized()
	
	# Combiner les comportements
	# Separation a priorité, puis gather, puis wander
	if separation_direction.length() > 0:
		direction = (separation_direction * separation_strength + wander_direction * 0.3).normalized()
	elif gather_count > 0:
		direction = (gather_direction * 0.6 + wander_direction * 0.4).normalized()
	
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
			print("💥 [KILL] Robert éliminé - Valeur: ", kill_value)
		
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
	
	# Ajuster la taille visuellement selon la valeur
	var base_scale = 1.0
	if value >= 10:
		base_scale = 2.5
	elif value >= 5:
		base_scale = 2.0
	elif value >= 3:
		base_scale = 1.5
	
	scale = Vector2.ONE * base_scale
	
	print("📊 [VALUE] Robert mis à jour - Valeur: %d, Échelle: %.1f" % [value, base_scale])

func destroy_silently() -> void:
	# Détruire sans effets (pour la fusion)
	_is_dying = true
	queue_free()
