class_name VenomSpitData
extends BaseSkillData
## 침 뱉기 전용 데이터. 목표 지점까지 포물선으로 뱉어(BaseLobbedProjectile 상속),
## 알 폭탄과 달리 착탄 시 즉시 폭발하지 않고 그 자리에 중독 장판(BaseAreaEffect,
## tick_interval>0)을 남깁니다 — 설계서 4-3 "즉발 폭발이 아니라 지속 장판형 DOT".

## Lv5 만렙 진화 시 형태. NONE = 진화 전(베이스), TOXIC_FIELD = 형태 A(맹독지대).
## 형태 B는 스킬설계.md 4-3에 "???(스킬 형태가 코그모 궁처럼 변경)"로 컨셉만 남아있고
## 구체 스펙이 없어 아직 미구현 — 기획 확정되면 이 enum에 값 추가 후 이어서 구현.
enum Evolution { NONE, TOXIC_FIELD }

@export_group("진화 형태")
@export var evolution: Evolution = Evolution.NONE

@export_group("투척")
@export var throw_range: float = 200.0  ## 조준(가장 가까운 적 탐색) 및 최대 투척 거리
@export var flight_time: float = 0.55   ## 뱉은 뒤 착탄까지 걸리는 시간(포물선 체공 시간)

@export_group("중독 장판 (레벨별, 인덱스 0 = Lv1)")
@export var level_zone_radius: Array[float] = [55.0, 55.0, 55.0, 55.0, 55.0]  ## 장판 반경. 설계서상 레벨별 변화 없음(Lv1 "기본 장판 크기"만 명시)
@export var level_zone_duration: Array[float] = [3.0, 3.0, 4.5, 4.5, 4.5]     ## 장판 지속시간. Lv3에서 증가(특징적 강화, 설계서 "장판 지속시간 증가")

@export_group("중독 틱")
@export var tick_interval: float = 0.5  ## 장판 안의 적을 이 간격으로 반복 타격(중독 틱 데미지)

@export_group("쿨타임 (레벨별, 인덱스 0 = Lv1)")
@export var level_cooldown_multiplier: Array[float] = [1.0, 0.85, 0.85, 0.7, 0.7]  ## cooldown에 곱하는 배율. Lv2/Lv4에서 감소(설계서 "Lv2: 쿨타임 감소", "Lv4: 쿨타임 감소")

@export_group("형태 A: 맹독지대 전용 (장판 대형화 + 감속)")
@export var toxic_field_radius_multiplier: float = 1.8  ## 기본 장판 반경에 곱해 대형화
@export var toxic_field_slow_multiplier: float = 0.5    ## 장판 안 적의 이동속도 배율(0.5 = 절반으로 감속)
@export var toxic_field_slow_duration: float = 1.0      ## 감속 지속시간(장판을 벗어나도 이 시간 동안은 유지)

## 스킬 레벨(1~5)에 맞는 장판 반경. 배열 범위를 벗어나면 마지막 값을 사용.
func zone_radius_for_level(level: int) -> float:
	return level_zone_radius[clampi(level - 1, 0, level_zone_radius.size() - 1)]

## 스킬 레벨(1~5)에 맞는 장판 지속시간. 배열 범위를 벗어나면 마지막 값을 사용.
func zone_duration_for_level(level: int) -> float:
	return level_zone_duration[clampi(level - 1, 0, level_zone_duration.size() - 1)]

## 스킬 레벨(1~5)에 맞는 쿨타임 배율. 배열 범위를 벗어나면 마지막 값을 사용.
func cooldown_multiplier_for_level(level: int) -> float:
	return level_cooldown_multiplier[clampi(level - 1, 0, level_cooldown_multiplier.size() - 1)]
