extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var enemies_container: Node2D = $Enemies
@onready var ui: CanvasLayer = $UI

var score: int = 0
var time_alive: float = 0.0
var spawn_timer: float = 0.0
var game_over: bool = false
var boss_timer: float = 45.0

var daily_seed: int = 0
var streak: int = 0
var best_score: int = 0

func _ready() -> void:
	_load_progress()
	_calculate_daily_seed()

	player.died.connect(_on_player_died)
	player.leveled_up.connect(_on_player_leveled_up)

	await get_tree().process_frame

	player.global_position = get_viewport_rect().size / 2

	ui.show_hud()
	ui.hide_upgrade()
	ui.hide_death()

func _process(delta: float) -> void:
	if game_over:
		return

	time_alive += delta
	spawn_timer -= delta
	boss_timer -= delta

	if spawn_timer <= 0.0:
		_spawn_enemy()
		spawn_timer = max(0.35, 1.1 - time_alive * 0.015)

	if boss_timer <= 0.0:
		_spawn_boss()
		boss_timer = 45.0

	ui.update_hud(player.hp, player.max_hp, score, player.level, time_alive, streak)

func _spawn_enemy() -> void:
	var enemy_scene = preload("res://scenes/Enemy.tscn")
	var e = enemy_scene.instantiate()

	var roll = randf()
	if time_alive < 30:
		e.enemy_type = e.EnemyType.NORMAL
	elif time_alive < 90:
		e.enemy_type = e.EnemyType.FAST if roll < 0.4 else e.EnemyType.NORMAL
	else:
		if roll < 0.3:
			e.enemy_type = e.EnemyType.FAST
		elif roll < 0.55:
			e.enemy_type = e.EnemyType.TANK
		else:
			e.enemy_type = e.EnemyType.NORMAL

	e.died.connect(_on_enemy_died)

	var viewport_size = get_viewport_rect().size
	var angle = randf() * TAU
	var dist = max(viewport_size.x, viewport_size.y) * 0.6
	e.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * dist

	var base_hp = 25 + time_alive * 1.8 + player.level * 4
	match e.enemy_type:
		e.EnemyType.FAST:
			e.max_hp = base_hp * 0.5
			e.speed = 70 + min(110, time_alive * 1.2) + 60
			e.damage = 8 + time_alive * 0.08
			e.xp_value = 4 + player.level * 0.4
		e.EnemyType.TANK:
			e.max_hp = base_hp * 3.0
			e.speed = max(35, 70 + min(110, time_alive * 1.2) - 45)
			e.damage = 16 + time_alive * 0.15
			e.xp_value = 12 + player.level * 0.8
		_:
			e.max_hp = base_hp
			e.speed = 70 + min(110, time_alive * 1.2)
			e.damage = 8 + time_alive * 0.1
			e.xp_value = 5 + player.level * 0.5

	e.hp = e.max_hp
	enemies_container.add_child(e)

func _spawn_boss() -> void:
	var enemy_scene = preload("res://scenes/Enemy.tscn")
	var e = enemy_scene.instantiate()
	e.enemy_type = e.EnemyType.BOSS
	e.died.connect(_on_enemy_died)

	var viewport_size = get_viewport_rect().size
	var angle = randf() * TAU
	var dist = max(viewport_size.x, viewport_size.y) * 0.7
	e.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * dist

	e.max_hp = 200 + time_alive * 6 + player.level * 20
	e.hp = e.max_hp
	e.speed = 55
	e.damage = 25 + time_alive * 0.2
	e.xp_value = 60 + player.level * 3

	enemies_container.add_child(e)
	player.screen_shake(8.0, 0.4)

func _on_enemy_died(_xp_value: float) -> void:
	score += 10 + int(time_alive)

func _on_player_leveled_up() -> void:
	get_tree().paused = true
	player.screen_shake(3.0, 0.2)
	ui.show_upgrade(player)

func _on_player_died() -> void:
	game_over = true
	_save_progress()
	ui.show_death(score, time_alive, player.level, streak, best_score)

func apply_upgrade(upgrade_name: String) -> void:
	match upgrade_name:
		"Damage +25%":
			player.damage *= 1.25
		"Fire Rate +20%":
			player.fire_rate *= 0.80
		"Move Speed +15%":
			player.speed *= 1.15
		"Max HP +30":
			player.max_hp += 30
			player.hp += 30
		"Magnet +40%":
			player.magnet_range *= 1.4
		"XP Gain +25%":
			player.xp_mult *= 1.25
		"Attack Range +20%":
			player.attack_range *= 1.2
		"Orbiting Blades":
			player.enable_blades()

	get_tree().paused = false
	ui.hide_upgrade()

func _calculate_daily_seed() -> void:
	var date = Time.get_date_dict_from_system()
	var date_str = "%04d-%02d-%02d" % [date.year, date.month, date.day]
	daily_seed = date_str.hash()

func _load_progress() -> void:
	var cfg = ConfigFile.new()
	if cfg.load("user://pulse_forge.cfg") == OK:
		streak = cfg.get_value("progress", "streak", 0)
		best_score = cfg.get_value("progress", "best_score", 0)

		var last_day = cfg.get_value("progress", "last_day", "")
		var today = Time.get_date_string_from_system()

		if last_day != today:
			if last_day != "":
				streak += 1
			else:
				streak = 1
	else:
		streak = 1

func _save_progress() -> void:
	best_score = max(best_score, score)
	var cfg = ConfigFile.new()
	cfg.set_value("progress", "streak", streak)
	cfg.set_value("progress", "best_score", best_score)
	cfg.set_value("progress", "last_day", Time.get_date_string_from_system())
	cfg.save("user://pulse_forge.cfg")
