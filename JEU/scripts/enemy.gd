extends CharacterBody2D

@export_group("Settings")
@export var SPEED: float = 100.0

var _current_target
var _is_dying: bool = false  # Empêche les multiples collisions

func _physics_process(_delta: float) -> void:
	# Ne plus bouger si en train de mourir
	if _is_dying:
		return
	
	var targets = get_tree().get_nodes_in_group("Player")
	
	if targets.is_empty():
		return
	
	_current_target = targets[0]
	
	var _direction_to_player = global_position.direction_to(_current_target.global_position)
	velocity = _direction_to_player * SPEED
	move_and_slide()

func _on_death_zone_body_entered(body: Node2D) -> void:
	# Éviter les doubles collisions
	if _is_dying:
		return
	
	print("Enemy touched by: ", body.name)
	
	if body.is_in_group("Player"):
		_is_dying = true
		
		# Déclencher le screenshake
		var camera = get_viewport().get_camera_2d()
		if camera and camera.has_method("apply_shake"):
			camera.apply_shake(5.0)  # Intensité du shake (ajustez selon vos besoins)
		
		# Trouver le node World et appeler add_kill
		var world = get_tree().current_scene
		
		if world and world.has_method("add_kill"):
			world.add_kill()
			print("Kill ajouté!")
		
		# Effet de mort
		if has_node("CPUParticles2D"):
			$CPUParticles2D.emitting = true
		
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.visible = false
		
		if has_node("CollisionShape2D"):
			$CollisionShape2D.disabled = true
		
		# Attendre la fin des particules (durée = lifetime des particules)
		await get_tree().create_timer(1.1).timeout
		queue_free()
