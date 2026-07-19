class_name BiteSkill
extends BaseMeleeSkill
## 물기 (기획서 4.2: 근접/흡입형, 티라노 시작 스킬).
## 사거리 내 가장 가까운 적 1체에게 즉시 데미지 — 범위 판정/타겟팅/데미지 적용은
## 전부 BaseMeleeSkill이 처리하므로, 여기서는 명중했을 때 흡입 이펙트만 스폰합니다.

## 명중한 적의 위치에 흡입 이펙트(skill_data.effect_scene)를 스폰.
func _on_hit(enemy: Enemy) -> void:
	if skill_data.effect_scene == null:
		return
	var effect: Node2D = skill_data.effect_scene.instantiate()
	owner_body.get_parent().add_child(effect)
	effect.global_position = enemy.global_position

func _indicator_color() -> Color:
	return Color(1.0, 0.9, 0.2, 0.35)
