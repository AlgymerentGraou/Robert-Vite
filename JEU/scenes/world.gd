extends Node2D

# Référence à la scène Cadran complète
@onready var cadran: CanvasLayer = $Cadran  # Remplacez par le nom exact de votre node Cadran
@onready var timer_level: Timer = $TimerLevel  # Remplacez par le nom exact de votre Timer

var current_kills: int = 0
var target_kills: int = 5
var current_wave: int = 1
var is_game_over: bool = false

func _ready():
	print("[World] _ready() appelé ✅")
	print(" - Cadran trouvé :", cadran != null)
	print(" - Timer trouvé :", timer_level != null)
	
	if not timer_level:
		push_error("❌ Timer non assigné dans l'inspecteur!")
		return
	
	start_wave()
	update_display()

func _process(delta: float) -> void:
	if is_game_over or not timer_level:
		return

	# Ratio du temps restant (1.0 = plein, 0.0 = vide)
	var ratio := 0.0
	if timer_level.wait_time > 0.0:
		ratio = clamp(timer_level.time_left / timer_level.wait_time, 0.0, 1.0)

	# Mise à jour du cadran
	update_display()

	# Vérifie si le timer est fini
	if timer_level.is_stopped():
		game_over()

func add_kill() -> void:
	if is_game_over:
		return

	current_kills += 1
	update_display()

	if current_kills >= target_kills:
		complete_wave()

func complete_wave() -> void:
	current_wave += 1
	current_kills = 0
	target_kills += 3
	start_wave()
	print("✅ Vague ", current_wave, " complétée ! Nouvel objectif: ", target_kills, " Roberts")

func start_wave() -> void:
	is_game_over = false
	if timer_level:
		timer_level.start()
		print("🚗 Nouvelle vague démarrée : durée = %.2fs" % timer_level.wait_time)
	update_display()

func update_display() -> void:
	if not cadran or not cadran.has_method("update_display"):
		return
	
	var time_left = 0.0
	var time_ratio = 0.0
	
	if timer_level and not timer_level.is_stopped():
		time_left = timer_level.time_left
		if timer_level.wait_time > 0.0:
			time_ratio = time_left / timer_level.wait_time
	
	# Appeler la méthode du cadran
	cadran.update_display(current_kills, target_kills, current_wave, time_left, time_ratio)

func game_over() -> void:
	is_game_over = true
	if timer_level:
		timer_level.stop()
	print("💀 Partie perdue ! Tu n'as pas tué assez de Roberts !")
	
	if cadran and cadran.has_method("show_game_over"):
		cadran.show_game_over()
