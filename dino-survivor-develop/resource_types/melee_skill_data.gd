class_name MeleeSkillData
extends BaseSkillData
## 즉시타격형(근접) 스킬의 공통 데이터. BaseMeleeSkill이 이 데이터를 읽어서
## "사거리/각도 판정 → 데미지"를 전부 처리합니다. 예: 물기(원형, 단일→다중 대상), 철퇴(부채꼴, 전체 대상).
##
## 사거리/각도/동시타격수를 전부 레벨별 배열로 둔 이유: 스킬마다 "몇 레벨에서 뭐가 세지는지"가
## 다 다르기 때문입니다(물기는 Lv3에 동시 타격 대상이 늘고, 철퇴는 Lv3에 부채꼴이 넓어지는 식).
## 새 즉시타격형 스킬은 보통 새 스크립트 없이 이 배열들과 시각 효과(effect_scene)만 채워서 추가할 수 있습니다.

## NEAREST_N = 가장 가까운 적 N체만(물기), ALL_IN_ARC = 판정 범위 안의 적 전체(철퇴)
enum TargetMode { NEAREST_N, ALL_IN_ARC }

@export_group("판정 범위 (레벨별, 인덱스 0 = Lv1)")
@export var level_range: Array[float] = [80.0, 80.0, 80.0, 80.0, 80.0]        ## 사거리(px)
@export var level_arc_degrees: Array[float] = [360.0, 360.0, 360.0, 360.0, 360.0]  ## 판정 각도. 360 = 전방위(원형) / 작을수록 부채꼴

@export_group("타이밍")
@export var hit_delay: float = 0.0  ## 스킬 발동부터 실제 판정까지의 선딜레이(예: 철퇴가 휘둘러지는 시간)

@export_group("대상 (레벨별, 인덱스 0 = Lv1)")
@export var target_mode: TargetMode = TargetMode.NEAREST_N
@export var level_target_count: Array[int] = [1, 1, 1, 1, 1]  ## target_mode == NEAREST_N일 때만 사용 (ALL_IN_ARC는 항상 전체)

## 스킬 레벨(1~5)에 맞는 사거리. 배열 범위를 벗어나면 마지막 값을 사용.
func range_for_level(level: int) -> float:
	return level_range[clampi(level - 1, 0, level_range.size() - 1)]

## 스킬 레벨(1~5)에 맞는 판정 각도. 배열 범위를 벗어나면 마지막 값을 사용.
func arc_degrees_for_level(level: int) -> float:
	return level_arc_degrees[clampi(level - 1, 0, level_arc_degrees.size() - 1)]

## 스킬 레벨(1~5)에 맞는 동시 타격 대상 수(NEAREST_N 모드 전용). 배열 범위를 벗어나면 마지막 값을 사용.
func target_count_for_level(level: int) -> int:
	return level_target_count[clampi(level - 1, 0, level_target_count.size() - 1)]
