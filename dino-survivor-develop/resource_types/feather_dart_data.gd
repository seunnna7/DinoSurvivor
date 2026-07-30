class_name FeatherDartData
extends BaseSkillData
## '깃털 다트' 전용 데이터. 레벨업/진화에 따라 사거리·관통·도탄·교차타격이
## 어떻게 바뀌는지를 전부 데이터로 표현합니다 (로직은 FeatherDartSkill/FeatherDartProjectile 담당).

## Lv5 만렙 진화 시 형태. NONE = 진화 전(베이스), CROSS_STRIKE = 형태 A(조준타격), RICOCHET = 형태 B(팅!)
enum Evolution { NONE, CROSS_STRIKE, RICOCHET }

@export_group("진화 형태")
@export var evolution: Evolution = Evolution.NONE

@export_group("레벨별 수치 (인덱스 0 = Lv1)")
@export var level_range: Array[float] = [160.0, 160.0, 260.0, 260.0, 260.0]  ## 사거리(px). Lv3부터 증가
@export var level_pierce_enabled: Array[bool] = [false, false, true, true, true]  ## Lv3부터 관통(경로상 적 타격) 활성화
@export var level_cooldown_multiplier: Array[float] = [1.0, 1.0, 1.0, 0.8, 0.8]  ## cooldown에 곱하는 배율. Lv4에서 연사력 강화(쿨타임 감소, 설계서 "Lv4: 쿨타임 감소")

@export_group("도착 지점 AOE")
@export var aoe_radius: float = 28.0  ## 최종 도착(또는 소멸) 지점 반경 이 안의 모든 적을 타격

@export_group("형태 A: 조준타격 (교차 타격)")
@export var shoulder_offset: float = 14.0  ## 좌/우 발사 지점이 플레이어 중심에서 떨어진 거리
@export var cross_damage_multiplier: float = 2.0  ## 교차 지점 및 도착 지점 데미지 배율

@export_group("형태 B: 팅! (도탄)")
@export var max_bounce_count: int = 3  ## 화면 테두리에 부딪혀 튕길 수 있는 최대 횟수

## 스킬 레벨(1~5)에 맞는 사거리. 배열 범위를 벗어나면 마지막 값을 사용.
func range_for_level(level: int) -> float:
	return level_range[clampi(level - 1, 0, level_range.size() - 1)]

## 스킬 레벨(1~5)에 맞는 관통 활성화 여부. 배열 범위를 벗어나면 마지막 값을 사용.
func pierce_for_level(level: int) -> bool:
	return level_pierce_enabled[clampi(level - 1, 0, level_pierce_enabled.size() - 1)]

## 스킬 레벨(1~5)에 맞는 쿨타임 배율. 배열 범위를 벗어나면 마지막 값을 사용.
func cooldown_multiplier_for_level(level: int) -> float:
	return level_cooldown_multiplier[clampi(level - 1, 0, level_cooldown_multiplier.size() - 1)]
