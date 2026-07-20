class_name BiteSkill
extends BaseMeleeSkill
## 물기 (기획서 4.2: 근접/흡입형, 티라노 시작 스킬).
## Direction Rule: Fixed Direction — 적을 탐색하지 않고, 플레이어가 바라보는 방향
## (facing_direction)으로 무조건 발동합니다. MeleeSkillData.range_for_level()은 더 이상
## "적 탐지 반경"이 아니라 "플레이어 위치에서 물기 이펙트가 앞으로 얼마나 나가서 스폰되는지"를
## 뜻하는 값으로 재사용합니다(사거리↔크기 분리 원칙은 그대로 — HITBOX_SIZE는 BiteHitEffect가
## 따로 들고 있는 고정값).
## 스폰 이후에도 owner_body를 넘겨서 BiteHitEffect가 애니메이션이 끝날 때까지 플레이어 위치를
## 계속 따라가게 합니다(플레이어가 씹는 도중 움직여도 항상 플레이어 앞에 붙어 있도록). 방향
## 자체는 발동 순간의 facing_direction으로 고정되고 이후 바뀌지 않습니다(Fixed Direction 규칙).
## 실제 데미지는 BaseMeleeSkill._fire()의 "발동 즉시 판정" 흐름을 쓰지 않고, 대신
## BiteHitEffect 안에서 "입이 완전히 닫히는" 정확한 타이밍에 한 번만 사각형 히트박스로
## 광역 데미지가 들어가도록 위임합니다. (실제 판정 로직은 BiteHitEffect._on_jaws_closed() 참고.)

func _fire() -> void:
	var melee_data := _melee_data()
	if melee_data.hit_delay > 0.0:
		await get_tree().create_timer(melee_data.hit_delay).timeout
	if skill_data.effect_scene == null:
		return
	var effect: BiteHitEffect = skill_data.effect_scene.instantiate()
	effect.damage = _leveled_damage()
	effect.knockback_distance = skill_data.knockback_distance
	effect.owner_body = owner_body
	effect.facing_direction = _current_facing()
	effect.reach = melee_data.range_for_level(level)
	owner_body.get_parent().add_child(effect)

func _indicator_color() -> Color:
	return Color(1.0, 0.9, 0.2, 0.35)
