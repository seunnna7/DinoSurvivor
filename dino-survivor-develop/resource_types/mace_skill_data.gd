class_name MaceSkillData
extends MeleeSkillData
## 철퇴 전용 데이터. MeleeSkillData(사거리/각도/대상수)는 그대로 물려받고,
## 철퇴만의 고유 수치인 넉백과, 진화 형태(전방향 휘두르기 / 내려찍기)를 추가로 정의합니다.

## Lv5 만렙 진화 시 형태. NONE = 진화 전(베이스), OMNI_SWING = 형태 A(전방향 휘두르기),
## SLAM = 형태 B(내려찍기). OMNI_SWING은 사실 level_arc_degrees를 360으로 주는 것만으로
## BaseMeleeSkill이 알아서 처리하므로 코드 분기가 필요 없고, SLAM만 MaceSkill이 직접 분기합니다.
enum Evolution { NONE, OMNI_SWING, SLAM }

@export_group("진화 형태")
@export var evolution: Evolution = Evolution.NONE

@export_group("넉백 (기본 스윙 / 형태 A 공통)")
@export var knockback_force: float = 220.0
@export var knockback_duration: float = 0.25

@export_group("형태 B: 내려찍기 전용")
@export var slam_radius: float = 100.0           ## 내려찍기는 부채꼴이 아니라 원형 AOE로 터짐
@export var slam_knockback_force: float = 420.0  ## 내려찍기는 훨씬 강하게 밀어냄
