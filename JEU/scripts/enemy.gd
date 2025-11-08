extends CharacterBody2D

@export_group("Settings")
@export var SPEED: float = 100.0

var _current_target

func _physics_process(delta: float) -> void:
	var targets = get_tree().get_nodes_in_group("Player")
	
	if targets.is_empty():
		return
	
	_current_target = targets[0]
	
	var _direction_to_player = global_position.direction_to(_current_target.global_position)
	velocity = _direction_to_player * SPEED
	move_and_slide()

func _on_death_zone_body_entered(body: Node2D) -> void:
	print("Enemy touched by: ", body.name)
	
	if body.is_in_group("Player"):
		# Trouver le node World et appeler add_kill
		var world = get_tree().current_scene
		
		if world and world.has_method("add_kill"):
			world.add_kill()
			print("Kill ajouté!")
		
		$CPUParticles2D.emitting = true
		$AnimatedSprite2D.visible = false
		$CollisionShape2D.disabled = true
		
		await get_tree().create_timer(1.1).timeout
		queue_free()
