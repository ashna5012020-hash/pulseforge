extends Area2D

@onready var visual: CanvasItem = $Visual

var xp_value: float = 5.0
var magnet_speed: float = 320.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	visual.modulate = Color(0.13, 0.83, 0.93)

func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var dist = global_position.distance_to(player.global_position)
	if dist < player.magnet_range:
		var dir = (player.global_position - global_position).normalized()
		global_position += dir * magnet_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.add_xp(xp_value)
		body.run_cores += xp_value
		queue_free()
