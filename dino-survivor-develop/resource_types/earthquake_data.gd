class_name EarthquakeData
extends BaseSkillData
## 지진 전용 데이터. 캐릭터가 바라보는 방향으로 직사각형(길이×폭) 범위를 내리쳐, 흔들림
## 전조(cast_delay) 후 그 범위 전체에 피해를 줍니다. 범위 크기는 레벨에 따라 변하지 않고
## (설계서 4-4), 데미지와 쿨타임만 레벨업 대상입니다.

## Lv5 만렙 진화 시 형태. NONE = 진화 전(베이스), CATACLYSM = 형태 A(대격변, 십자형 균열),
## AFTERSHOCK = 형태 B(여진, 같은 자리에 시차를 두고 2차 균열). 둘 다 EarthquakeSkill이 직접 분기.
enum Evolution { NONE, CATACLYSM, AFTERSHOCK }

@export_group("진화 형태")
@export var evolution: Evolution = Evolution.NONE

@export_group("범위")
@export var rect_size: Vector2 = Vector2(260.0, 90.0)  ## 길이(x) × 폭(y). 레벨과 무관하게 고정.
@export var cast_delay: float = 0.55  ## 살짝 흔들리다 갈라지기까지의 전조 시간(초)

@export_group("쿨타임 (레벨별, 인덱스 0 = Lv1)")
@export var level_cooldown_multiplier: Array[float] = [1.0, 1.0, 0.85, 0.85, 0.85]  ## Lv3에서 쿨타임 감소(설계서 "Lv3 — 데미지 증가 + 쿨감")

@export_group("형태 B: 여진 전용")
@export var aftershock_delay: float = 0.6  ## 1차 균열 발동 후 2차 균열(여진)까지의 시차
@export var aftershock_damage_multiplier: float = 0.65  ## 2차 균열 데미지는 1차보다 약함(지속 딜 강화형)

## 스킬 레벨(1~5)에 맞는 쿨타임 배율. 배열 범위를 벗어나면 마지막 값을 사용.
func cooldown_multiplier_for_level(level: int) -> float:
	return level_cooldown_multiplier[clampi(level - 1, 0, level_cooldown_multiplier.size() - 1)]
