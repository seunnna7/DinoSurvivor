class_name BaseMeleeSkill
extends BaseSkill
## 근접/즉시타격형 스킬(물기, 철퇴 등)의 공통 로직.
## "사거리 원(또는 부채꼴) 안의 적을 즉시 타격"이라는 패턴을 MeleeSkillData로 전부 표현하고,
## 하위 클래스는 시각 효과 훅 두 개(_on_swing, _on_hit)만 구현하면 됩니다.
##
## MeleeSkillData로 표현되는 것 (전부 레벨별 배열 — 스킬마다 성장 곡선이 다르기 때문):
##   - level_range / level_arc_degrees : 사거리와 타격 각도(360 = 원형, 물기 / 90 = 부채꼴, 철퇴)
##   - level_target_count              : NEAREST_N 모드일 때 동시에 맞는 대상 수(물기: Lv3에 1→2)
##   - target_mode                     : NEAREST_N(가장 가까운 N체, 물기) / ALL_IN_ARC(범위 전체, 철퇴)
##   - hit_delay                       : 판정까지의 선딜레이(예: 철퇴가 휘둘러지는 0.4초, 레벨 무관)
##
## 새 근접 스킬을 추가하려면:
##   1. data/skills/에 MeleeSkillData .tres 추가 (레벨별 배열만 채우면 끝, 새 스크립트가 필요 없을 수도 있음)
##   2. 시각 효과가 필요하면 이 클래스를 상속하는 스크립트를 작성해 _on_swing()/_on_hit()만 오버라이드

func setup(data: SkillData, body: Node2D) -> void:
	super.setup(data, body)
	var melee_data := _melee_data()
	_show_range_indicator(
		melee_data.range_for_level(level), _indicator_color(), melee_data.arc_degrees_for_level(level)
	)

func _fire() -> void:
	var melee_data := _melee_data()
	if melee_data.hit_delay > 0.0:
		await get_tree().create_timer(melee_data.hit_delay).timeout
	var facing := _current_facing()
	_on_swing(facing)
	for enemy in _gather_targets(facing):
		enemy.take_damage(_leveled_damage())
		_on_hit(enemy)

func _melee_data() -> MeleeSkillData:
	return skill_data as MeleeSkillData

## 플레이어가 바라보는 방향. arc_degrees == 360(전방위)이면 어느 값이어도 판정 결과에 영향 없음.
func _current_facing() -> Vector2:
	return owner_body.get("facing_direction")

## target_mode에 따라 "범위 내 전체" 또는 "가장 가까운 적 N체"를 반환.
func _gather_targets(facing: Vector2) -> Array[Enemy]:
	var melee_data := _melee_data()
	var in_arc := _enemies_in_arc(facing)
	if melee_data.target_mode == MeleeSkillData.TargetMode.ALL_IN_ARC:
		return in_arc
	in_arc.sort_custom(_by_distance_to_owner)
	return in_arc.slice(0, melee_data.target_count_for_level(level))

func _by_distance_to_owner(a: Enemy, b: Enemy) -> bool:
	var origin := owner_body.global_position
	return origin.distance_to(a.global_position) < origin.distance_to(b.global_position)

## 사거리/각도 판정을 통과하는 모든 Enemy.
func _enemies_in_arc(facing: Vector2) -> Array[Enemy]:
	var result: Array[Enemy] = []
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy := node as Enemy
		if enemy != null and _is_in_arc(facing, enemy.global_position):
			result.append(enemy)
	return result

## 사거리 원(또는 arc_degrees < 360이면 facing 기준 부채꼴) 안에 target_pos가 들어오는지 판정.
func _is_in_arc(facing: Vector2, target_pos: Vector2) -> bool:
	var origin := owner_body.global_position
	var melee_data := _melee_data()
	if origin.distance_to(target_pos) > melee_data.range_for_level(level):
		return false
	var arc_degrees := melee_data.arc_degrees_for_level(level)
	if arc_degrees >= 360.0:
		return true
	var to_target := target_pos - origin
	if to_target.length() < 0.001:
		return true
	return abs(facing.angle_to(to_target)) <= deg_to_rad(arc_degrees) / 2.0

## 하위 클래스 오버라이드용. hit_delay가 끝난 시점(판정 직전) 1회 호출 — 스윙 전체를 대표하는
## 시각 효과에 사용(예: 철퇴의 부채꼴 잔상). 개별 대상과 무관하게 딱 한 번만 호출됩니다.
func _on_swing(_facing: Vector2) -> void:
	pass

## 하위 클래스 오버라이드용. 실제로 데미지를 받은 적마다 호출 — 개별 타격 시각 효과에 사용(예: 물기 이펙트).
func _on_hit(_enemy: Enemy) -> void:
	pass
