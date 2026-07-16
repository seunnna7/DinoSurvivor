extends Node
## Autoload 싱글톤. 런을 넘나드는 영구 진행 상태(보유 골드, 메타 강화 레벨)를 관리합니다.
## data/meta_upgrades/의 MetaUpgradeData를 skill_database.gd와 같은 방식으로 스캔하고,
## user://meta_progress.json에 뮤테이션마다 즉시 저장합니다 (별도의 "저장" 버튼 없음).

const UPGRADES_PATH := "res://data/meta_upgrades/"
const SAVE_PATH := "user://meta_progress.json"

signal gold_changed(new_total: int)                        ## 보유 골드 UI가 구독
signal upgrade_changed(id: StringName, new_level: int)      ## 강화 창이 버튼 상태 갱신에 사용

var gold: int = 0
var upgrade_levels: Dictionary = {}   ## StringName(강화 id) -> int(레벨)
var all_upgrades: Array[MetaUpgradeData] = []

func _ready() -> void:
	_load_all_upgrades()
	_load_save()

func _load_all_upgrades() -> void:
	var dir := DirAccess.open(UPGRADES_PATH)
	if dir == null:
		push_warning("메타 강화 데이터 폴더를 찾을 수 없습니다: %s" % UPGRADES_PATH)
		return
	for file_name in dir.get_files():
		if file_name.ends_with(".tres"):
			all_upgrades.append(load(UPGRADES_PATH + file_name))

func get_upgrade(id: StringName) -> MetaUpgradeData:
	for u in all_upgrades:
		if u.id == id:
			return u
	return null

func upgrade_level(id: StringName) -> int:
	return upgrade_levels.get(id, 0)

## 런이 게임 오버 될 때 game_over_ui가 1회 호출. 이번 판 골드를 보유 골드에 합산.
func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)
	_save()

## 강화 구매 시도. 골드 부족/최대 레벨이면 아무 일도 하지 않고 false를 반환.
func try_purchase(id: StringName) -> bool:
	var data := get_upgrade(id)
	if data == null:
		return false
	var level := upgrade_level(id)
	if level >= data.max_level:
		return false
	var cost := data.cost_for_level(level + 1)
	if gold < cost:
		return false
	gold -= cost
	upgrade_levels[id] = level + 1
	gold_changed.emit(gold)
	upgrade_changed.emit(id, level + 1)
	_save()
	return true

## 구매한 강화들을 StatModifierData로 변환. Player._modifiers()가 종족 패시브와 합쳐서 사용.
func get_modifiers() -> Array[StatModifierData]:
	var mods: Array[StatModifierData] = []
	for u in all_upgrades:
		var level := upgrade_level(u.id)
		if level <= 0:
			continue
		var mod := StatModifierData.new()
		mod.source_type = StatModifierData.SourceType.META_UPGRADE
		mod.source_id = u.id
		mod.stat_id = u.stat_id
		mod.modifier_type = u.modifier_type
		mod.value = u.value_per_level * level
		mods.append(mod)
	return mods

func _save() -> void:
	var levels := {}
	for id in upgrade_levels:
		levels[String(id)] = upgrade_levels[id]
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("세이브 파일을 쓸 수 없습니다: %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify({"gold": gold, "upgrade_levels": levels}))

func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	gold = int(parsed.get("gold", 0))
	var levels: Dictionary = parsed.get("upgrade_levels", {})
	for id_str in levels:
		upgrade_levels[StringName(id_str)] = int(levels[id_str])
