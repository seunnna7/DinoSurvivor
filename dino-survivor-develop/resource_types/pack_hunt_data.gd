class_name PackHuntData
extends BaseSkillData
## 무리 사냥 전용 데이터. 발동할 때마다 플레이어 주변 임의의 위치(들)에 발톱 할퀴기
## (ClawSwipeArea, BaseAreaEffect 기반)를 소환합니다.

## Lv5 만렙 진화 시 형태. NONE = 진화 전(베이스), BLEED_MULTI = 형태 A(비열한 협공, 다단히트+출혈),
## HUNTING_ZONE = 형태 B(공격명령, 추적하는 지속 영역 하나를 소환).
enum Evolution { NONE, BLEED_MULTI, HUNTING_ZONE }

@export_group("진화 형태")
@export var evolution: Evolution = Evolution.NONE

@export_group("공격 범위/횟수 (레벨별, 인덱스 0 = Lv1)")
@export var level_radius: Array[float] = [55.0, 55.0, 70.0, 70.0, 70.0]  ## 발톱 자국 하나의 반경. Lv3에서 증가(특징적 강화)
@export var level_strike_count: Array[int] = [1, 2, 2, 3, 3]  ## 한 번 발동에 동시에 나타나는 발톱 자국 개수

@export_group("연출")
@export var fade_duration: float = 0.5  ## 기본형: 할퀸 자국이 유지되다 사라지기까지 걸리는 시간
@export var spawn_radius_around_player: float = 260.0  ## 플레이어 중심 이 반경 안 임의의 위치에 소환

@export_group("형태 A: 비열한 협공 전용 (다단히트 + 출혈)")
@export var multi_hit_tick_interval: float = 0.4  ## 다단히트 간격
@export var multi_hit_duration: float = 1.6       ## 다단히트가 지속되는 시간(자국이 사라지기까지)
@export var bleed_damage_per_second: float = 4.0
@export var bleed_duration: float = 2.0

@export_group("형태 B: 공격명령 전용 (추적하는 지속 영역)")
@export var zone_radius: float = 100.0
@export var zone_duration: float = 4.0
@export var zone_move_speed: float = 40.0
@export var zone_tick_interval: float = 0.5

## 스킬 레벨(1~5)에 맞는 발톱 자국 반경. 배열 범위를 벗어나면 마지막 값을 사용.
func radius_for_level(level: int) -> float:
	return level_radius[clampi(level - 1, 0, level_radius.size() - 1)]

## 스킬 레벨(1~5)에 맞는 동시 발톱 자국 개수. 배열 범위를 벗어나면 마지막 값을 사용.
func strike_count_for_level(level: int) -> int:
	return level_strike_count[clampi(level - 1, 0, level_strike_count.size() - 1)]
