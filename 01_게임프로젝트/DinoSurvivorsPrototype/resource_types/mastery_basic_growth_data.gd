class_name MasteryBasicGrowthData
extends Resource
## 숙련도 매 레벨마다 오르는 기초 스탯 성장분. 엑셀 MasteryBasicGrowth 시트와 1:1 대응.
## stat_id는 반드시 StatTypes.is_basic()이 true인 스탯만 사용 (기획서 6.3 원칙).
## 종족별 개별 (기획서 6.3). 세이브 시스템 필요 — M3 이후 구현 예정.

@export var species_id: StringName
@export var stat_id: StringName
@export var modifier_type: StatModifierData.ModifierType = StatModifierData.ModifierType.ADDITIVE_FLAT
@export var value_per_level: float = 1.0
