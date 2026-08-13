class_name HornBoomerangData
extends BaseSkillData
## '뿔메랑' 전용 데이터. 조준 방향으로 뿔을 던지면 이차함수(포물선) 전진에 사인 곡선의 좌우
## 흔들림을 얹어 물방울(테어드롭) 모양을 그리며 던진 자리로 되돌아와 그 자리에서 소멸합니다.
## 손으로 돌아오는 게 아니라 궤적이 끝나는 지점에서 사라진다는 점에 주의(설계서 6-1).
## 궤적을 지나는 모든 적에게 관통 피해(가는 길·오는 길 모두 히트)를 주는 게 이 스킬의 기본
## 정체성이라, 다른 스킬처럼 "관통 활성화 레벨"이 따로 없고 항상 관통합니다.

## Lv5 만렙 진화 시 형태. NONE = 진화 전(베이스), TWIN = 형태 A(이중 뿔메랑), WILD_CURVE = 형태 B(광폭 곡선)
enum Evolution { NONE, TWIN, WILD_CURVE }

@export_group("진화 형태")
@export var evolution: Evolution = Evolution.NONE

@export_group("궤적")
@export var forward_range: float = 220.0  ## 던진 지점에서 궤적이 가장 멀리 나가는 거리(포물선 정점)
@export var lateral_amplitude: float = 90.0  ## 좌우로 부풀어 오르는 폭(물방울 모양의 폭)
@export var loop_duration: float = 0.45  ## 왕복 1회(물방울 한 바퀴)에 걸리는 시간(초)

@export_group("레벨별 수치 (인덱스 0 = Lv1)")
@export var level_loop_count: Array[int] = [1, 1, 2, 2, 2]  ## Lv3부터 왕복 2회(8자 궤적, 설계서 "이제 8자로 움직임")

@export_group("형태 B: 광폭 곡선 전용")
@export var wild_curve_scale_multiplier: float = 2.2  ## 도착 지점에서 커지는 크기 배율
@export var wild_curve_spin_duration: float = 0.5  ## 회전 데미지가 지속되는 시간(초)
@export var wild_curve_tick_interval: float = 0.15  ## 회전 데미지 틱 간격(초)
@export var wild_curve_radius: float = 60.0  ## 회전 데미지 판정 반경

## 스킬 레벨(1~5)에 맞는 왕복 횟수. 배열 범위를 벗어나면 마지막 값을 사용.
func loop_count_for_level(level: int) -> int:
	return level_loop_count[clampi(level - 1, 0, level_loop_count.size() - 1)]
