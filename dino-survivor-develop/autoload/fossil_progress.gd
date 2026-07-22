extends Node
## Autoload 싱글톤. 화석 복원(캐릭터 해금) 진행 상태를 관리합니다.
## SpeciesData 자체에는 해금 여부를 두지 않고, meta_progress.gd와 동일한 방식으로
## user://fossil_progress.json에 뮤테이션마다 즉시 저장합니다.

const SAVE_PATH := "user://fossil_progress.json"
const DEFAULT_UNLOCKED: Array[StringName] = [&"trex"]  ## 세이브 파일이 없을 때(최초 실행) 기본으로 해금되는 종족

signal unlock_changed(id: StringName)  ## 화석 복원 UI가 카드 갱신에 사용

var unlocked_ids: Dictionary = {}  ## StringName(종족 id) -> true

func _ready() -> void:
	_load_save()

func is_unlocked(id: StringName) -> bool:
	return unlocked_ids.get(id, false)

## 해금하기 버튼에서 호출. 지금은 조건 없이 즉시 해금하는 간이 로직 (추후 화석 조각/골드 소모 등으로 교체 예정)
func unlock(id: StringName) -> void:
	if is_unlocked(id):
		return
	unlocked_ids[id] = true
	unlock_changed.emit(id)
	_save()

func _save() -> void:
	var ids := []
	for id in unlocked_ids:
		ids.append(String(id))
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("화석 복원 세이브 파일을 쓸 수 없습니다: %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify({"unlocked_ids": ids}))

func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		for id in DEFAULT_UNLOCKED:
			unlocked_ids[id] = true
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var ids: Array = parsed.get("unlocked_ids", [])
	for id_str in ids:
		unlocked_ids[StringName(id_str)] = true
