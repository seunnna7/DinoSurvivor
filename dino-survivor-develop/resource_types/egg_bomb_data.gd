class_name EggBombData
extends BaseSkillData
## 알 폭탄 전용 데이터. 목표 지점까지 포물선으로 던져(BaseLobbedProjectile 상속),
## 착탄 시 폭발(기본형 / 형태 A "특란")하거나 미니 알을 산개(형태 B "알다발")시킵니다.

## Lv5 만렙 진화 시 형태. NONE = 진화 전(베이스), BIG_EGG = 형태 A(특란), EGG_CLUSTER = 형태 B(알다발).
## BIG_EGG는 aoe_radius/cooldown을 데이터로만 키우면 되므로 코드 분기가 필요 없고,
## EGG_CLUSTER만 EggBombProjectile이 "폭발 대신 산개"로 직접 분기합니다.
enum Evolution { NONE, BIG_EGG, EGG_CLUSTER }

@export_group("진화 형태")
@export var evolution: Evolution = Evolution.NONE

@export_group("투척")
@export var throw_range: float = 220.0  ## 조준(가장 가까운 적 탐색) 및 최대 투척 거리
@export var flight_time: float = 0.5    ## 던진 뒤 착탄까지 걸리는 시간(포물선 체공 시간)

@export_group("폭발 (레벨별, 인덱스 0 = Lv1)")
@export var level_aoe_radius: Array[float] = [50.0, 50.0, 65.0, 65.0, 65.0]  ## Lv3에서 폭발 범위 증가(특징적 강화)

@export_group("형태 B: 알다발 전용")
@export var mine_count: int = 5                ## 착탄 지점 주변에 흩뿌려지는 미니 알 개수
@export var mine_scatter_radius: float = 70.0  ## 미니 알들이 착탄 지점 주변에 퍼지는 반경
@export var mine_radius: float = 30.0          ## 미니 알 1개의 폭발 반경
@export var mine_lifetime: float = 6.0         ## 안 밟히면 이 시간 뒤 자동 소멸

## 스킬 레벨(1~5)에 맞는 폭발 반경. 배열 범위를 벗어나면 마지막 값을 사용.
func aoe_radius_for_level(level: int) -> float:
	return level_aoe_radius[clampi(level - 1, 0, level_aoe_radius.size() - 1)]
