extends RefCounted
class_name StatCalculator
## 기획서 6.4에서 제안한 중첩 규칙(additive_percent 통일안)을 실제로 구현.
## ⚠️ 이 규칙은 기획서 8장 미해결 사항(9번)에 따라 아직 팀 확정 전입니다 — 확정되면 이 계산 순서만 손보면 됩니다.
##
## 계산 순서: additive_flat을 먼저 다 더함 → additive_percent는 서로 합산한 뒤 한 번에 곱함
## → multiplicative는 각각 곱함 (되도록 지양 권장, 기획서 참고)

static func compute(base_value: float, stat_id: StringName, modifiers: Array[StatModifierData]) -> float:
	var flat_sum := 0.0
	var percent_sum := 0.0
	var mult_product := 1.0

	for mod in modifiers:
		if mod == null or mod.stat_id != stat_id:
			continue
		match mod.modifier_type:
			StatModifierData.ModifierType.ADDITIVE_FLAT:
				flat_sum += mod.value
			StatModifierData.ModifierType.ADDITIVE_PERCENT:
				percent_sum += mod.value
			StatModifierData.ModifierType.MULTIPLICATIVE:
				mult_product *= (1.0 + mod.value / 100.0)

	var result := (base_value + flat_sum) * (1.0 + percent_sum / 100.0) * mult_product
	return result
