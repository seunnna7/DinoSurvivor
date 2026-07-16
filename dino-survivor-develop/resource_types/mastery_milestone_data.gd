class_name MasteryMilestoneData
extends Resource
## 숙련도 N레벨마다(간격 미정 — 기획서 8장) 고유 액티브/패시브를 직접 강화.
## 엑셀 MasteryMilestones 시트와 1:1 대응.
##
## target 표기 규칙: 점(.)이 있으면 "스킬id.수치필드" (예: "bite.base_damage"),
## 없으면 "passive"(종족 패시브 전체) 또는 Stats의 stat_id로 해석.

@export var species_id: StringName
@export var milestone_level: int = 3
@export var target: String  ## 예: "bite.base_damage", "passive", "max_health"
@export var modifier_type: StatModifierData.ModifierType = StatModifierData.ModifierType.ADDITIVE_PERCENT
@export var value: float = 0.0
@export var description: String
