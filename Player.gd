extends CharacterBody2D

signal died
signal leveled_up

@onready var camera: Camera2D = $Camera2D
@onready var visual: CanvasItem = $Visual

var max_hp: float = 100.0
var hp: float = 100.0
var speed: float = 220.0
var damage: float = 12.0
var fire_rate: float = 0.35
var fire_timer: float = 0.0
var attack_range: float = 220.0
var magnet_range: float = 90.0
var xp_mult: float = 1.0

var xp: float = 0.0
var xp_to_next: float = 20.0
var level: int = 1

# Orbiting blades weapon
var has_blades: bool = false
var blade_count: int = 0
var blade_nodes: Array = []
var blade_angle: float = 0.0
var blade_radius: float = 70.0
var blade_damage: float = 8.0
var blade_rot_speed: float = 2.2

# Screen shake
var shake_time: float = 0.0
var shake_strength: float = 0.0

var run_cores: float = 0.0

func _ready() -> void:
	add_to_group("player")
	visual.modulate = Color(0.38, 0.65, 0.98)

	max_hp += SaveManager.upgrades.get("hp", 0) * 10.0
	hp = max_hp
	damage += SaveManager.upgrades.get("damage", 0) * 2.0
	speed += SaveManager.upgrades.get("speed", 0) * 8.0
	fire_rate = max(0.12, fire_rate - SaveManager.upgrades.get("fire_rate", 0) * 0.02)
	if SaveManager.upgrades.get("blades", 0) >= 1:
		enable_blades()

func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO
	dir.x = Input.get_axis("ui_left", "ui_right")
	dir.y = Input.get_axis("ui_up", "ui_down")

	if Input.is_key_pressed(KEY_A): dir.x -= 1
	if Input.is_key_pressed(KEY_D): dir.x += 1
	if Input.is_key_pressed(KEY_W): dir.y -= 1
	if Input.is_key_pressed(KEY_S): dir.y += 1

	if dir.length() > 0:
		dir = dir.normalized()
		velocity = dir * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * 8.0 * delta)

	move_and_slide()

	var viewport_size = get_viewport_rect().size
	global_position.x = clamp(global_position.x, 20, viewport_size.x - 20)
	global_position.y = clamp(global_position.y, 20, viewport_size.y - 20)

	fire_timer -= delta
	if fire_timer <= 0.0:
		_try_shoot()
		fire_timer = fire_rate

	if has_blades:
		_update_blades(delta)

	_update_shake(delta)

func _try_shoot() -> void:
	var nearest: Node2D = null
	var nearest_dist := attack_range

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var d = global_position.distance_to(enemy.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = enemy

	if nearest:
		var projectile_scene = preload("res://scenes/Projectile.tscn")
		var p = projectile_scene.instantiate()
		p.global_position = global_position
		p.direction = (nearest.global_position - global_position).normalized()
		p.damage = damage
		get_parent().add_child(p)

func take_damage(amount: float) -> void:
	hp -= amount
	screen_shake(4.0, 0.15)
	if hp <= 0:
		hp = 0
		died.emit()

func add_xp(amount: float) -> void:
	xp += amount * xp_mult
	while xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next = floor(xp_to_next * 1.35)
		leveled_up.emit()

func enable_blades() -> void:
	has_blades = true
	blade_count = min(blade_count + 1, 6)
	_rebuild_blades()

func _rebuild_blades() -> void:
	for b in blade_nodes:
		if is_instance_valid(b):
			b.queue_free()
	blade_nodes.clear()

	for i in range(blade_count):
		var blade = Area2D.new()
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 9
		shape.shape = circle
		blade.add_child(shape)

		var blade_visual = Polygon2D.new()
		blade_visual.polygon = PackedVector2Array([Vector2(-9,-9), Vector2(9,-9), Vector2(9,9), Vector2(-9,9)])
		blade_visual.color = Color(0.95, 0.9, 0.2)
		blade.add_child(blade_visual)

		blade.body_entered.connect(_on_blade_hit)
		get_parent().add_child(blade)
		blade_nodes.append(blade)

func _update_blades(delta: float) -> void:
	blade_angle += blade_rot_speed * delta
	for i in range(blade_nodes.size()):
		var b = blade_nodes[i]
		if not is_instance_valid(b):
			continue
		var offset_angle = blade_angle + (TAU / blade_count) * i
		b.global_position = global_position + Vector2(cos(offset_angle), sin(offset_angle)) * blade_radius

func _on_blade_hit(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(blade_damage)

func screen_shake(strength: float, duration: float) -> void:
	shake_strength = max(shake_strength, strength)
	shake_time = max(shake_time, duration)

func _update_shake(delta: float) -> void:
	if shake_time > 0.0:
		shake_time -= delta
		camera.offset = Vector2(randf_range(-1,1), randf_range(-1,1)) * shake_strength
	else:
		camera.offset = Vector2.ZERO
