extends CharacterBody2D

signal died(xp_value: float)

enum EnemyType { NORMAL, FAST, TANK, BOSS }

@onready var visual: CanvasItem = $Visual

var enemy_type: EnemyType = EnemyType.NORMAL
var max_hp: float = 30.0
var hp: float = 30.0
var speed: float = 90.0
var damage: float = 12.0
var xp_value: float = 5.0

func _ready() -> void:
	add_to_group("enemies")
	hp = max_hp
	_apply_type_visuals()

func _apply_type_visuals() -> void:
	match enemy_type:
		EnemyType.NORMAL:
			visual.modulate = Color(0.94, 0.27, 0.27)
			scale = Vector2(1.0, 1.0)
		EnemyType.FAST:
			visual.modulate = Color(1.0, 0.6, 0.1)
			scale = Vector2(0.65, 0.65)
		EnemyType.TANK:
			visual.modulate = Color(0.5, 0.15, 0.5)
			scale = Vector2(1.6, 1.6)
		EnemyType.BOSS:
			visual.modulate = Color(1.0, 0.1, 0.8)
			scale = Vector2(2.6, 2.6)

func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var dir = (player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

	if global_position.distance_to(player.global_position) < 28 * scale.x:
		player.take_damage(damage * delta)

func take_damage(amount: float) -> void:
	hp -= amount
	_flash_hit()
	if hp <= 0:
		_die()

func _flash_hit() -> void:
	var tween = create_tween()
	visual.modulate = Color(1, 1, 1)
	tween.tween_property(visual, "modulate", _base_color(), 0.12)

func _base_color() -> Color:
	match enemy_type:
		EnemyType.FAST: return Color(1.0, 0.6, 0.1)
		EnemyType.TANK: return Color(0.5, 0.15, 0.5)
		EnemyType.BOSS: return Color(1.0, 0.1, 0.8)
		_: return Color(0.94, 0.27, 0.27)

func _die() -> void:
	died.emit(xp_value)
	_spawn_death_burst()

	var orb_scene = preload("res://scenes/Orb.tscn")
	var orb = orb_scene.instantiate()
	orb.global_position = global_position
	orb.xp_value = xp_value
	get_parent().add_child(orb)

	queue_free()

func _spawn_death_burst() -> void:
	var parent = get_parent()
	var count = 8
	for i in range(count):
		var p = ColorRect.new()
		p.size = Vector2(5, 5)
		p.color = _base_color()
		p.global_position = global_position
		parent.add_child(p)

		var angle = (TAU / count) * i
		var target = global_position + Vector2(cos(angle), sin(angle)) * randf_range(20, 45)

		var tween = p.create_tween()
		tween.set_parallel(true)
		tween.tween_property(p, "global_position", target, 0.35)
		tween.tween_property(p, "modulate:a", 0.0, 0.35)
		tween.chain().tween_callback(p.queue_free)
