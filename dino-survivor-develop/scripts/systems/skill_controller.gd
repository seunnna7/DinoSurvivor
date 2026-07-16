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
		RunState.skill_leveled_up.emit(data, RunState.skill_levels[id])
		return

	RunState.skill_levels[id] = 1
	RunState.owned_skills.append(data)
	if data.logic_scene != null:
		var instance: SkillInstanceBase = data.logic_scene.instantiate()
		add_child(instance)
		instance.setup(data, owner_body)
		_instances[id] = instance
	RunState.skill_acquired.emit(data)
