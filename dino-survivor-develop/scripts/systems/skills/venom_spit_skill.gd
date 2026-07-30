class_name VenomSpitSkill
extends BaseSkill
## 침 뱉기: 가장 가까운 적의 위치(없으면 바라보는 방향으로 throw_range만큼 떨어진 지점)를
## 목표로 독액을 포물선으로 뱉습니다. 실제 이동/착탄 판정 및 착탄 후 중독 장판 생성은
## BaseLobbedProjectile을 상속한 VenomSpitProjectile이 전담하므로, 여기서는 "어디로 뱉을지"와
## "뱉을 독액의 수치 세팅"만 합니다 (EggBombSkill과 동일한 곡사 투사체 계열 공용 패턴).

const PROJECTILE_SCENE := preload("res://scenes/skills/VenomSpitProjectile.tscn")

func setup(data: SkillData, body: Node2D) -> void:
	super.setup(data, body)
	_show_range_indicator((data as VenomSpitData).throw_range, _indicator_color())

func _fire() -> void:
	var data := skill_data as VenomSpitData
	var landing_point := _pick_landing_point(data)

	var spit: VenomSpitProjectile = PROJECTILE_SCENE.instantiate()
	spit.damage = _leveled_damage()
	spit.knockback_distance = data.knockback_distance
	spit.flight_time = data.flight_time
	spit.aoe_radius = data.zone_radius_for_level(level)
	spit.zone_duration = data.zone_duration_for_level(level)
	spit.tick_interval = data.tick_interval
	spit.evolution = data.evolution
	spit.toxic_field_radius_multiplier = data.toxic_field_radius_multiplier
	spit.toxic_field_slow_multiplier = data.toxic_field_slow_multiplier
	spit.toxic_field_slow_duration = data.toxic_field_slow_duration
	owner_body.get_parent().add_child(spit)
	spit.launch(owner_body.global_position, landing_point)

## 가장 가까운 적이 있으면 그 자리를, 없으면 바라보는 방향으로 throw_range만큼 떨어진 지점을 조준.
func _pick_landing_point(data: VenomSpitData) -> Vector2:
	var target := _find_nearest_enemy(data.throw_range)
	if target != null:
		return target.global_position
	var facing: Vector2 = owner_body.get("facing_direction")
	return owner_body.global_position + facing * data.throw_range

## Lv2/Lv4에서 쿨타임이 감소하도록, 데이터에 적힌 레벨별 배율을 cooldown에 곱함.
func _leveled_cooldown() -> float:
	var data := skill_data as VenomSpitData
	return data.cooldown * data.cooldown_multiplier_for_level(level)

func _indicator_color() -> Color:
	return Color(0.55, 0.85, 0.25, 0.35)
