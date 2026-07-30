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
		_cooldown_timer = _leveled_cooldown()
		_perform()

## 하위 클래스에서 반드시 override. 실제 공격/효과 로직.
func _perform() -> void:
	push_warning("SkillInstanceBase._perform()이 구현되지 않았습니다: %s" % skill_data.id)

## 하위 클래스 오버라이드용. 기본은 스킬 데이터의 고정 쿨타임(skill_data.cooldown) 그대로.
## 레벨에 따라 쿨타임이 줄어드는 스킬(예: 알 폭탄 Lv5)은 이 함수를 오버라이드.
func _leveled_cooldown() -> float:
	return skill_data.cooldown

## 사거리를 원형(또는 arc_degrees < 360이면 owner_body가 바라보는 방향의 부채꼴) 아웃라인으로
## 표시하고 싶은 하위 클래스에서 setup() 오버라이드 중 호출.
## owner_body의 자식으로 붙기 때문에 캐릭터를 따라 실시간으로 이동/회전합니다.
func _show_range_indicator(radius: float, ring_color: Color = Color(1.0, 1.0, 1.0, 0.35), arc_degrees: float = 360.0) -> void:
	var indicator := SkillRangeIndicator.new()
	indicator.radius = radius
	indicator.ring_color = ring_color
	indicator.arc_degrees = arc_degrees
	if arc_degrees < 360.0:
		indicator.facing_source = owner_body
	owner_body.add_child.call_deferred(indicator)

## 하위 클래스에서 반드시 override(BaseSkill이 스킬 데이터의 레벨별 배율 BaseSkillData.level_damage로 구현).
func _leveled_damage() -> float:
	push_warning("SkillInstanceBase._leveled_damage()이 구현되지 않았습니다: %s" % skill_data.id)
	return 0.0
