extends Sprite2D

@export var start_angle_deg: float = 270.0
@export var end_angle_deg: float = 630.0

func update_from_ratio(ratio: float) -> void:
	var start_angle = deg_to_rad(start_angle_deg)
	var end_angle = deg_to_rad(end_angle_deg)

	var new_rot = lerp(end_angle, start_angle, ratio)

	rotation = new_rot
