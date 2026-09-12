extends Control

@onready var cores_label: Label = $CoresLabel
@onready var hp_button: Button = $VBoxContainer/HPButton
@onready var damage_button: Button = $VBoxContainer/DamageButton
@onready var speed_button: Button = $VBoxContainer/SpeedButton
@onready var fire_rate_button: Button = $VBoxContainer/FireRateButton
@onready var blades_button: Button = $VBoxContainer/BladesButton
@onready var play_button: Button = $PlayButton

func _ready() -> void:
	SaveManager.load_game()
	SaveManager.cores = 500
	_refresh()
	hp_button.pressed.connect(func(): _buy("hp"))
	damage_button.pressed.connect(func(): _buy("damage"))
	speed_button.pressed.connect(func(): _buy("speed"))
	fire_rate_button.pressed.connect(func(): _buy("fire_rate"))
	blades_button.pressed.connect(func(): _buy("blades"))
	play_button.pressed.connect(_on_play_pressed)

func _buy(key: String) -> void:
	if SaveManager.buy_upgrade(key):
		_refresh()
	else:
		print("Not enough cores for: ", key)

func _refresh() -> void:
	cores_label.text = "Cores: %d" % SaveManager.cores
	hp_button.text = "Max HP +10 (Lv %d/%d) - %d cores" % [SaveManager.upgrades["hp"], SaveManager.UPGRADE_MAX["hp"], SaveManager.get_upgrade_cost("hp")]
	damage_button.text = "Damage +2 (Lv %d/%d) - %d cores" % [SaveManager.upgrades["damage"], SaveManager.UPGRADE_MAX["damage"], SaveManager.get_upgrade_cost("damage")]
	speed_button.text = "Speed +8 (Lv %d/%d) - %d cores" % [SaveManager.upgrades["speed"], SaveManager.UPGRADE_MAX["speed"], SaveManager.get_upgrade_cost("speed")]
	fire_rate_button.text = "Fire Rate Up (Lv %d/%d) - %d cores" % [SaveManager.upgrades["fire_rate"], SaveManager.UPGRADE_MAX["fire_rate"], SaveManager.get_upgrade_cost("fire_rate")]
	blades_button.text = "Unlock Blades (Lv %d/%d) - %d cores" % [SaveManager.upgrades["blades"], SaveManager.UPGRADE_MAX["blades"], SaveManager.get_upgrade_cost("blades")]

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
