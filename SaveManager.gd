class_name SaveManager
extends RefCounted

const SAVE_PATH := "user://save.json"

static var cores: int = 0
static var upgrades: Dictionary = {
	"hp": 0,
	"damage": 0,
	"speed": 0,
	"fire_rate": 0,
	"blades": 0
}

const UPGRADE_MAX := {
	"hp": 10,
	"damage": 10,
	"speed": 10,
	"fire_rate": 8,
	"blades": 1
}

const UPGRADE_BASE_COST := {
	"hp": 15,
	"damage": 20,
	"speed": 15,
	"fire_rate": 25,
	"blades": 100
}

static func get_upgrade_cost(key: String) -> int:
	var level = upgrades.get(key, 0)
	return int(UPGRADE_BASE_COST[key] * pow(1.15, level))

static func can_afford(key: String) -> bool:
	if upgrades[key] >= UPGRADE_MAX[key]:
		return false
	return cores >= get_upgrade_cost(key)

static func buy_upgrade(key: String) -> bool:
	if not can_afford(key):
		return false
	cores -= get_upgrade_cost(key)
	upgrades[key] += 1
	save_game()
	return true

static func add_cores(amount: int) -> void:
	cores += amount
	save_game()

static func save_game() -> void:
	var data = {"cores": cores, "upgrades": upgrades}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

static func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY:
			cores = parsed.get("cores", 0)
			var loaded = parsed.get("upgrades", {})
			for key in upgrades.keys():
				if loaded.has(key):
					upgrades[key] = loaded[key]
