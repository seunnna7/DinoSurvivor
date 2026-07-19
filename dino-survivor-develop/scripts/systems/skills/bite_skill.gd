class_name BiteSkill
extends BaseMeleeSkill
## 물기 (기획서 4.2: 근접/흡입형, 티라노 시작 스킬).
## 발동 판정 범위는 지금도 원형입니다 — MeleeSkillData.range_for_level()을 반경으로 하는
## 원 안에서 가장 가까운 적을 찾고(적이 없으면 발동하지 않음), 플레이어 위치가 아니라
## 그 적이 있는 지점에 물기 애니메이션(BiteHitEffect)을 스폰합니다. 방향은 여전히
## "플레이어 → 적" 방향으로 맞춰서, 턱이 플레이어 쪽에서 적 쪽을 향해 닫히는 것처럼 보이게 함.
## 실제 데미지는 BaseMeleeSkill._fire()의 "발동 즉시 판정" 흐름을 쓰지 않고, 대신
## BiteHitEffect 안에서 "입이 완전히 닫히는" 정확한 타이밍에 한 번만 사각형 히트박스로
## 광역 데미지가 들어가도록 위임합니다. (실제 판정 로직은 BiteHitEffect._on_jaws_closed() 참고.)

func _fire() -> void:
	var melee_data := _melee_data()
	var target := _find_nearest_enemy(melee_data.range_for_level(level))
	if target == null:
		return
	if melee_data.hit_delay > 0.0:
		await get_tree().create_timer(melee_data.hit_delay).timeout
		if not is_instance_valid(target):
			return
	if skill_data.effect_scene == null:
		return
	var effect: BiteHitEffect = skill_data.effect_scene.instantiate()
	effect.damage = _leveled_damage()
	effect.base_width = melee_data.range_for_level(level) * 2.0
	effect.range_scale = _range_scale_for_level()
	effect.facing = owner_body.global_position.direction_to(target.global_position)
	effect.global_position = target.global_position
	owner_body.get_parent().add_child(effect)

## 물기 범위가 아이템/레벨업으로 늘어날 때 이 배율만 조정하면 BiteHitEffect의 히트박스와
## 이펙트 스프라이트(bite_top/bite_bottom)가 같은 비율로 함께 커집니다 — 확장 기능이 생기면
## 여기서 해당 시스템 값을 읽어 반환하도록 채우면 됨. 지금은 확장 수단이 없어 1.0 고정.
func _range_scale_for_level() -> float:
	return 1.0

func _indicator_color() -> Color:
	return Color(1.0, 0.9, 0.2, 0.35)
