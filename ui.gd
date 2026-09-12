extends CanvasLayer

@onready var hud: Control = $HUD
@onready var hp_label: Label = $HUD/HPLabel
@onready var score_label: Label = $HUD/ScoreLabel
@onready var level_label: Label = $HUD/LevelLabel
@onready var time_label: Label = $HUD/TimeLabel
@onready var streak_label: Label = $HUD/StreakLabel

@onready var upgrade_panel: Control = $UpgradePanel
@onready var option1: Button = $UpgradePanel/OptionsContainer/Option1
@onready var option2: Button = $UpgradePanel/OptionsContainer/Option2
@onready var option3: Button = $UpgradePanel/OptionsContainer/Option3

@onready var death_panel: Control = $DeathPanel
@onready var result_label: Label = $DeathPanel/ResultLabel
@onready var again_button: Button = $DeathPanel/AgainButton
@onready var menu_button: Button = $DeathPanel/MenuButton

var upgrade_pool := [
	"Damage +25%",
	"Fire Rate +20%",
	"Move Speed +15%",
	"Max HP +30",
	"Magnet +40%",
	"XP Gain +25%",
	"Attack Range +20%",
	"Orbiting Blades",
]

var main_ref: Node2D

func _ready() -> void:
	main_ref = get_parent()
	upgrade_panel.visible = false
	death_panel.visible = false

	option1.pressed.connect(func(): _pick(option1.text))
	option2.pressed.connect(func(): _pick(option2.text))
	option3.pressed.connect(func(): _pick(option3.text))

	again_button.pressed.connect(_on_again)
	menu_button.pressed.connect(_on_menu)

func show_hud() -> void:
	hud.visible = true

func update_hud(hp: float, max_hp: float, score: int, level: int, time_alive: float, streak: int) -> void:
	hp_label.text = "HP: %d / %d" % [ceil(hp), int(max_hp)]
	score_label.text = "Score: %d" % score
	level_label.text = "Level: %d" % level
	time_label.text = "Time: %.1fs" % time_alive
	streak_label.text = "Streak: %d days" % streak

func hide_upgrade() -> void:
	upgrade_panel.visible = false

func show_upgrade(_player) -> void:
	var pool_copy = upgrade_pool.duplicate()
	pool_copy.shuffle()
	option1.text = pool_copy[0]
	option2.text = pool_copy[1]
	option3.text = pool_copy[2]
	upgrade_panel.visible = true

func _pick(choice: String) -> void:
	main_ref.apply_upgrade(choice)

func hide_death() -> void:
	death_panel.visible = false

func show_death(score: int, time_alive: float, level: int, streak: int, best: int) -> void:
	result_label.text = "Run Over\n\nScore: %d\nTime: %.1fs\nLevel: %d\nStreak: %d days\nBest: %d" % [score, time_alive, level, streak, max(best, score)]
	death_panel.visible = true

func _on_again() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
