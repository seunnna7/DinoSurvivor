class_name SkillController
extends Node
## Player의 자식 노드로 부착. 장착된 스킬(SkillData)들을 실제 동작(SkillInstanceBase)으로
## 변환해 관리합니다. acquire_skill()이 신규 획득/레벨업 UI의 유일한 진입점입니다.

@export var starting_skill_ids: Array[StringName] = [&"bite", &"mace"]  ## 프로토타입은 티라노 1종 고정이라 하드코딩. 종족 다양화 시 SpeciesData에서 가져오도록 변경 예정.

var owner_body: Node2D
var _instances: Dictionary = {}  # StringName(스킬 id) -> SkillInstanceBase

func _ready() -> void:
	owner_body = get_parent()
	for id in starting_skill_ids:
		acquire_skill(id)

## 스킬을 새로 획득하거나(레벨 1로 시작), 이미 보유 중이면 레벨만 올립니다.
## 레벨업 카드 UI는 선택된 스킬 id로 이 함수 하나만 호출하면 됩니다.
func acquire_skill(id: StringName) -> void:
	var data := SkillDatabase.get_skill(id)
	if data == null:
		push_warning("스킬 데이터를 찾을 수 없습니다: %s" % id)
		return

	if RunState.is_skill_owned(id):
		RunState.skill_levels[id] += 1
		if _instances.has(id):
			_instances[id].level = RunState.skill_levels[id]
		RunState.skill_leveled_up.emit(data, RunState.skill_levels[id])
		if RunState.skill_levels[id] >= data.max_level and not data.evolutions.is_empty():
			RunState.evolution_ready.emit(data)
		return

	RunState.skill_levels[id] = 1
	RunState.owned_skills.append(data)
	if data.logic_scene != null:
		var instance: SkillInstanceBase = data.logic_scene.instantiate()
		add_child(instance)
		instance.setup(data, owner_body)
		_instances[id] = instance
	RunState.skill_acquired.emit(data)

## 진화 선택 UI에서 하나를 고르면 호출됩니다. 베이스 스킬을 슬롯에서 제거하고
## 그 자리를 진화형 스킬로 대체합니다 (기획서 4.3).
func evolve_skill(base_id: StringName, evolution_data: SkillData) -> void:
	if _instances.has(base_id):
		_instances[base_id].queue_free()
		_instances.erase(base_id)
	RunState.remove_skill(base_id)

	RunState.skill_levels[evolution_data.id] = evolution_data.max_level
	RunState.owned_skills.append(evolution_data)
	if evolution_data.logic_scene != null:
		var instance: SkillInstanceBase = evolution_data.logic_scene.instantiate()
		add_child(instance)
		instance.setup(evolution_data, owner_body)
		_instances[evolution_data.id] = instance
	RunState.skill_acquired.emit(evolution_data)
