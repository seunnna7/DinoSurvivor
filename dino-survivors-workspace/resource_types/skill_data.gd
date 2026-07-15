class_name SkillData
extends Resource
## 스킬 하나를 정의하는 데이터 리소스.
## 새 스킬을 추가할 때 이 스크립트를 건드릴 필요 없이,
## 이 스키마를 기반으로 data/skills/ 안에 새 .tres 파일만 만들면 됩니다.
## (Godot 에디터에서 우클릭 > New Resource > SkillData 로 생성 가능)

enum Archetype {
	MELEE,          ## 근접 (예: 철퇴)
	ORBIT,          ## 몸 주변 회전 (예: 골판 두르기)
	DASH,           ## 돌진 (예: 박치기)
	SUMMON,         ## 소환 (예: 새끼낳기)
	BURST,          ## 주기적 광역 (예: 음파)
	RANGED_PIERCE,  ## 원거리 관통 (예: 손톱 미사일)
	RANGED_SPREAD,  ## 원거리 확산 (예: 산탄)
	SUCTION,        ## 흡입형 (예: 물기)
	PASSIVE,        ## 패시브 (예: 긴 목)
}

enum Stance { QUADRUPED, BIPED, BOTH }

@export var id: StringName
@export var display_name: String
@export var species_motif: String
@export_multiline var flavor_text: String  ## 플레이버 텍스트 보이스 공식 적용 (기획서 4.1.1)

@export_group("분류")
@export var archetype: Archetype = Archetype.MELEE
@export var is_unique_active: bool = false  ## true면 공용 풀에 노출 안 됨 (특정 종족 전용)
@export var preferred_stance: Stance = Stance.BOTH

@export_group("수치")
@export var base_damage: float = 10.0
@export var cooldown: float = 1.0
@export var max_level: int = 5  ## 각성(만렙) 기준

@export_group("씬 참조")
@export var effect_scene: PackedScene  ## 투사체/이펙트 씬 (있는 경우)
@export var logic_scene: PackedScene   ## 이 스킬의 실제 동작을 구현한 로직 씬 (SkillInstanceBase 상속). 비어있으면 "더미"(UI에만 존재, 실제 동작 없음)

@export_group("표시")
@export var icon_color: Color = Color(0.8, 0.8, 0.8, 1.0)  ## 스킬 아이콘 자리표시용 색상 (실제 아이콘 이미지로 교체 전까지)
