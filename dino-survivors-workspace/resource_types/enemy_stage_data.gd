class_name EnemyStageData
extends Resource
## 몹의 "한 단계"를 정의하는 데이터. 씬은 Enemy.tscn 하나만 쓰고,
## 이 리소스로 종류를 구분합니다 (스킬 시스템과 동일한 데이터-로직 분리 원칙).
##
## 새 몹을 추가하고 싶으면 코드를 건드리지 않고 이 스키마 기반 .tres 파일만
## data/enemies/ 에 추가하면 됩니다.

enum Tier {
	NORMAL,  ## 일반 몹 (예: 쥐 → 고양이 → ...)
	ELITE,   ## 정예 개체
	BOSS,    ## 보스
}

@export var id: StringName
@export var display_name: String  ## 예: "쥐", "고양이"
@export var tier: Tier = Tier.NORMAL
@export var stage: int = 1  ## 같은 티어 내 진행 단계 (1, 2, 3...) — 클수록 나중/강함
@export var unlock_time: float = 0.0  ## 생존 시간(초)이 이 값을 넘으면 같은 티어의 이전 단계를 대체

@export_group("전투 수치")
@export var max_health: float = 20.0
@export var move_speed: float = 80.0
@export var contact_damage: float = 5.0

@export_group("스폰 규칙")
@export var spawn_interval: float = 1.5  ## NORMAL/ELITE 전용 (반복 스폰 간격)
@export var spawn_count_per_tick: int = 1  ## NORMAL/ELITE 전용
## BOSS 티어는 위 두 값을 무시하고, unlock_time에 딱 1회만 스폰됩니다.

@export_group("비주얼 (임시 도형)")
@export var visual_scale: float = 1.0
@export var visual_color: Color = Color(0.75, 0.2, 0.2, 1)

@export_group("드랍")
@export var loot_table: LootTable
