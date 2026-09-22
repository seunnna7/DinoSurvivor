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
	fuse_if_possible()  ## 이번 진화로 어떤 레시피의 재료가 방금 채워졌을 수 있음 — 트리거 아이템을 먼저 갖고 있던 경우 대비

## 합체 트리거 아이템을 새로 얻거나 재료 스킬이 진화를 마칠 때마다 호출됩니다.
## 조건(재료 전부 진화 완료 + 트리거 아이템 보유)을 만족하는 레시피가 있으면 즉시 발동합니다
## (기획서 4.5 "재료가 전부 진화를 마친 상태에서 트리거 아이템을 보유하면 즉시 합체").
func fuse_if_possible() -> void:
	for recipe in FusionDatabase.all_recipes:
		if _can_fuse(recipe):
			_perform_fusion(recipe)
			return  # 한 번의 호출에 레시피 하나만 발동 — 여러 레시피가 동시에 조건을 만족해도 순서대로 처리됨

func _can_fuse(recipe: FusionRecipe) -> bool:
	if RunState.fusion_trigger_count < 1:
		return false
	for ingredient in recipe.ingredients:
		if RunState.skill_level(ingredient.id) < ingredient.max_level:
			return false
	return true

## 재료 스킬들을 슬롯에서 제거하고(액티브 슬롯 반환), 트리거 아이템을 소모한 뒤
## 합체 결과 스킬을 곧바로 만렙 상태로 장착합니다 (evolve_skill()과 동일한 패턴).
func _perform_fusion(recipe: FusionRecipe) -> void:
	for ingredient in recipe.ingredients:
		remove_skill(ingredient.id)
	RunState.add_fusion_trigger(-1)

	var result := recipe.result
	RunState.skill_levels[result.id] = result.max_level
	RunState.owned_skills.append(result)
	if result.logic_scene != null:
		var instance: SkillInstanceBase = result.logic_scene.instantiate()
		add_child(instance)
		instance.setup(result, owner_body)
		_instances[result.id] = instance
	RunState.skill_acquired.emit(result)
	RunState.fusion_completed.emit(result)

## 개발자 메뉴 전용 — 보유 스킬을 레벨과 무관하게 완전히 제거합니다 (인스턴스 노드도 함께 정리).
## scripts/debug/dev_menu.gd와 함께 지우면 됩니다.
func remove_skill(id: StringName) -> void:
	if not RunState.is_skill_owned(id):
		return
	if _instances.has(id):
		_instances[id].queue_free()
		_instances.erase(id)
	RunState.remove_skill(id)

## 개발자 메뉴 전용 — 스킬 레벨을 정확한 값으로 지정합니다 (0 이하면 완전히 제거).
## scripts/debug/dev_menu.gd와 함께 지우면 됩니다.
func dev_set_skill_level(id: StringName, level: int) -> void:
	if level <= 0:
		remove_skill(id)
		return
	if not RunState.is_skill_owned(id):
		acquire_skill(id)
	RunState.skill_levels[id] = level
	if _instances.has(id):
		_instances[id].level = level
