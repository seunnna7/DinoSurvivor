class_name SkillInstanceBase
extends Node
## 장착된 스킬 하나의 "실행 로직"을 담당하는 베이스 클래스.
##
## 새 스킬을 추가하는 절차:
##   1. data/skills/에 SkillData .tres 추가 (수치/텍스트)
##   2. 이 클래스를 상속하는 스크립트 작성 후 _perform()만 구현 (실제 동작)
##   3. 그 스크립트를 붙인 작은 씬을 만들어 SkillData.logic_scene에 연결
## SkillController는 이 구조를 통해 "어떤 스킬이든" 동일한 방식으로 다룰 수 있습니다.

var skill_data: SkillData
var level: int = 1
var owner_body: Node2D

var _cooldown_timer: float = 0.0

func setup(data: SkillData, body: Node2D) -> void:
	skill_data = data
	owner_body = body

func _process(delta: float) -> void:
	if skill_data == null:
		return
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		_cooldown_timer = skill_data.cooldown
		_perform()

## 하위 클래스에서 반드시 override. 실제 공격/효과 로직.
func _perform() -> void:
	push_warning("SkillInstanceBase._perform()이 구현되지 않았습니다: %s" % skill_data.id)

## 레벨에 따른 데미지 배율. 간단한 선형 증가 (추후 밸런싱 시 조정 예정)
func _leveled_damage() -> float:
	return skill_data.base_damage * (1.0 + 0.2 * float(level - 1))
