class_name StatModifierData
extends Resource
## 패시브/버프 효과 하나를 "어떤 스탯을, 어떻게, 얼마나" 바꾸는지로 구조화.
## 기획서 6.4 / 엑셀 StatModifiers 시트와 1:1 대응.
## 자유 텍스트 패시브 설명(예: "공격력 +10%") 대신 이 리소스를 실제 계산에 사용합니다.

enum SourceType { SPECIES_PASSIVE, SKILL_PASSIVE, STANCE, META_UPGRADE, MASTERY }
enum ModifierType { ADDITIVE_FLAT, ADDITIVE_PERCENT, MULTIPLICATIVE }

@export var source_type: SourceType = SourceType.SPECIES_PASSIVE
@export var source_id: StringName  ## 예: "trex", "quadruped"
@export var stat_id: StringName    ## 점(.)이 있으면 좌변 해석이 source_type에 따라 다름 — SKILL_PASSIVE는 "태그.효과필드"(그 태그를 가진 스킬 전체를 겨냥, 예: "projectile.range"), MASTERY는 "스킬id.수치필드"(특정 스킬 하나를 직접 지정, 예: "bite.base_damage"). 점이 없으면 StatTypes에 정의된 전역 스탯
@export var modifier_type: ModifierType = ModifierType.ADDITIVE_PERCENT
@export var value: float = 0.0
