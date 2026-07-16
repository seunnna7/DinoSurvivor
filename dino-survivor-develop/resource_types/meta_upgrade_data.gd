class_name MetaUpgradeData
extends Resource
## 골드로 구매하는 영구 강화 1종. 엑셀 MetaUpgrades 시트와 1:1 대응.
## 종족 공용 (기획서 6.3). data/meta_upgrades/의 .tres로 정의되며,
## 실제 구매/저장/스탯 반영은 autoload/meta_progress.gd가 담당합니다.

@export var id: StringName
@export var display_name: String
@export var stat_id: StringName
@export var modifier_type: StatModifierData.ModifierType = StatModifierData.ModifierType.ADDITIVE_PERCENT
@export var value_per_level: float = 1.0
@export var cost_base: int = 100
@export var cost_growth: float = 1.15
@export var max_level: int = 10

## 비용 공식: cost_base × cost_growth ^ (현재레벨-1)
func cost_for_level(level: int) -> int:
	return int(round(cost_base * pow(cost_growth, level - 1)))
