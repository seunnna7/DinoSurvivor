class_name BaseSkill
extends SkillInstanceBase
## 확장형 스킬 프레임워크의 실행 로직 앵커. 모든 스킬 로직 클래스는 이 클래스 — 또는 이 클래스를
## 다시 상속하는 "아키타입 베이스"(예: BaseMeleeSkill, BaseOrbitSkill) — 를 상속해야 합니다.
##
## 부모(SkillInstanceBase)가 이미 쿨타임 관리(_process)와 레벨/소유자 보관을 담당하므로,
## 이 클래스는 그 위에 네 가지만 얹습니다:
##   1. _perform() 대신 _fire()라는 이름으로 오버라이드하도록 강제 (발사형 스킬 어휘에 맞춤)
##   2. 투사체/근접/위성형 스킬 전반에서 반복되는 "가장 가까운 적 탐색" 공용 헬퍼
##   3. 사거리 표시 링 색상을 스킬마다 다르게 지정할 수 있는 훅
##   4. 레벨별 데미지 계산을 BaseSkillData.level_damage 배열 기반으로 오버라이드
##      (부모의 _leveled_damage()는 모든 스킬에 같은 선형 공식을 강제하지만, 스킬마다
##      레벨업 곡선이 달라야 하므로 여기서 스킬 데이터가 들고 있는 배열을 그대로 따르게 함)
##
## ── 스킬 아키타입 3종 (현재 구현된 것) ──────────────────────────────
##   BaseSkill            : 위 세 가지만 제공하는 최소 기반. 아래 두 아키타입에 안 맞는
##                           특수한 스킬(예: 순간 버프, 소환)은 이 클래스를 직접 상속해 _fire()만 구현.
##   BaseMeleeSkill        : 즉시타격형(물기, 철퇴). 사거리/부채꼴 판정을 데이터로 표현.
##   BaseOrbitSkill        : 위성 공전형(골판 두르기). _process()로 상시 갱신, 쿨타임 미사용.
##   (BaseProjectile은 Area2D 투사체 자체의 베이스이며, BaseSkill이 아니라 발사 스킬의 _fire()가
##    스폰하는 대상입니다. 깃털 다트가 이 조합의 예시.)
##
## 새 아키타입(예: 장판형, 유도형)이 필요하면 이 클래스를 상속하는 새 Base*Skill을 추가하고
## 위 목록에 한 줄 추가해주세요 — 이 주석이 프레임워크 전체의 지도 역할을 합니다.
##
## 새 스킬을 이 프레임워크로 추가하는 절차:
##   1. resource_types/에 BaseSkillData(또는 아키타입 전용 Data, 예: MeleeSkillData)를 상속하는
##      전용 Data 리소스 작성 (수치, 레벨별 배열, 진화 Enum 등)
##   2. 적합한 아키타입(BaseSkill/BaseMeleeSkill/BaseOrbitSkill)을 상속하는 스크립트 작성 후
##      필요한 훅만 구현 (완전히 새로운 동작이면 BaseSkill을 직접 상속해 _fire() 구현)
##   3. 발사형이라면 BaseProjectile을 상속하는 투사체 클래스를 추가로 작성해 _fire()에서 스폰
##   4. 작은 로직 씬을 만들어 SkillData.logic_scene에 연결

func _perform() -> void:
	_fire()

## 하위 클래스에서 반드시 override. 스킬 발동 시 실제 로직(발사/장판 생성/위성 갱신 등).
func _fire() -> void:
	push_warning("BaseSkill._fire()이 구현되지 않았습니다: %s" % skill_data.id)

## 하위 클래스 오버라이드용. _show_range_indicator()가 그리는 사거리 링의 색상.
## 스킬 컨셉에 맞게 커스터마이즈(예: 물기=노랑, 철퇴=주황, 골판=올리브).
func _indicator_color() -> Color:
	return Color(1.0, 1.0, 1.0, 0.35)

## 부모(SkillInstanceBase)의 고정 선형 공식(레벨당 +20%) 대신, 스킬 데이터에 적힌
## 레벨별 배율(BaseSkillData.level_damage)을 그대로 따릅니다 — 스킬마다 다른 성장 곡선을
## 코드 수정 없이 .tres 값만으로 표현하기 위함.
## owner_body는 항상 Player이므로 그쪽의 damage_multiplier(메타 강화 반영)를 곱함.
func _leveled_damage() -> float:
	var mult := 1.0
	if owner_body is Player:
		mult = (owner_body as Player).damage_multiplier
	return (skill_data as BaseSkillData).damage_for_level(level) * mult

## owner_body 기준 반경 max_range 이내에서 가장 가까운 Enemy를 찾습니다. 없으면 null.
## 발사형/유도형 스킬 전반에서 타겟팅에 공용으로 사용.
func _find_nearest_enemy(max_range: float = INF) -> Enemy:
	var nearest: Enemy = null
	var nearest_dist := max_range
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy := node as Enemy
		if enemy == null:
			continue
		var dist := owner_body.global_position.distance_to(enemy.global_position)
		if dist <= nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest
