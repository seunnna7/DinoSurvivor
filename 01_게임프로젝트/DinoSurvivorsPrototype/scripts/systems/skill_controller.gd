extends Node
## Player의 자식 노드로 부착. 장착된 스킬(SkillData)들을 실제 동작(SkillInstanceBase)으로
## 변환해 관리합니다. 슬롯 UI/레벨업 연결은 G4에서 이어집니다.

@export var starting_skill_ids: Array[StringName] = [&"bite"]  ## 프로토타입은 티라노 1종 고정이라 하드코딩. 종족 다양화 시 SpeciesData에서 가져오도록 변경 예정.

var owner_body: Node2D
var _instances: Array[SkillInstanceBase] = []

func _ready() -> void:
	owner_body = get_parent()
	for id in starting_skill_ids:
		equip_skill(id)

func equip_skill(id: StringName) -> void:
	var data := SkillDatabase.get_skill(id)
	if data == null:
		push_warning("스킬 데이터를 찾을 수 없습니다: %s" % id)
		return
	if data.logic_scene == null:
		push_warning("스킬에 logic_scene이 지정되지 않았습니다: %s" % id)
		return
	var instance: SkillInstanceBase = data.logic_scene.instantiate()
	add_child(instance)
	instance.setup(data, owner_body)
	_instances.append(instance)
	RunState.equipped_skills.append(data)
