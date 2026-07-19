class_name OrbitSkillData
extends BaseSkillData
## 위성 공전형 스킬의 공통 데이터. BaseOrbitSkill이 이 데이터를 읽어서 오브젝트 N개를
## 플레이어 주위로 공전시킵니다. 예: 골판 두르기.
## 이 아키타입은 상시 지속형이라 base SkillData.cooldown(쿨타임 트리거)을 사용하지 않고,
## 대신 hit_interval(같은 적에 대한 재타격 간격)을 별도 필드로 명시적으로 둡니다.

@export_group("궤도")
@export var orbit_radius: float = 60.0  ## 플레이어 중심으로부터의 공전 반지름(px)
@export var rotation_speed: float = 2.0 ## 공전 각속도(rad/sec)

@export_group("공전 오브젝트 개수 (레벨별, 인덱스 0 = Lv1)")
@export var level_orbit_body_count: Array[int] = [3, 3, 3, 3, 3]  ## 동시에 공전하는 오브젝트 개수

@export_group("타격")
@export var hit_interval: float = 0.4  ## 같은 적이 계속 겹쳐 있을 때 재타격되는 간격(초)

## 스킬 레벨(1~5)에 맞는 공전 오브젝트 개수. 배열 범위를 벗어나면 마지막 값을 사용.
func body_count_for_level(level: int) -> int:
	return level_orbit_body_count[clampi(level - 1, 0, level_orbit_body_count.size() - 1)]
