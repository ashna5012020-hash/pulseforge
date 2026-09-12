extends Area2D

@onready var visual: CanvasItem = $Visual

var direction: Vector2 = Vector2.RIGHT
var speed: float = 450.0
var damage: float = 10.0
var lifetime: float = 1.3

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	visual.modulate = Color(0.58, 0.77, 0.99)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()

func _on_area_entered(_area: Area2D) -> void:
	pass
