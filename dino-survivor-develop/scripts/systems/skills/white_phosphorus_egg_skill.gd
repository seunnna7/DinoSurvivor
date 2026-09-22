class_name WhitePhosphorusEggSkill
extends BaseSkill
## 백린란: 가장 가까운 적의 위치(없으면 바라보는 방향으로 throw_range만큼 떨어진 지점)를
## 목표로 알을 포물선으로 던집니다. EggBombSkill/VenomSpitSkill과 동일한 곡사 투사체 패턴.

const PROJECTILE_SCENE := preload("res://scenes/skills/WhitePhosphorusEggProjectile.tscn")

func setup(data: SkillData, body: Node2D) -> void:
	super.setup(data, body)
	_show_range_indicator((data as WhitePhosphorusEggData).throw_range, _indicator_color())

func _fire() -> void:
	var data := skill_data as WhitePhosphorusEggData
	var landing_point := _pick_landing_point(data)
	var distance := owner_body.global_position.distance_to(landing_point)
	var explosion_damage := _leveled_damage()

	var egg: WhitePhosphorusEggProjectile = PROJECTILE_SCENE.instantiate()
	egg.damage = explosion_damage
	egg.knockback_distance = skill_data.knockback_distance
	egg.flight_time = BaseLobbedProjectile.flight_time_for_distance(
		distance, data.throw_range, data.min_flight_time, data.max_flight_time
	)
	egg.aoe_radius = data.aoe_radius
	egg.zone_radius = data.zone_radius
	egg.zone_duration = data.zone_duration
	egg.tick_interval = data.tick_interval
	egg.zone_damage = explosion_damage * data.zone_damage_ratio
	owner_body.get_parent().add_child(egg)
	egg.launch(owner_body.global_position, landing_point)

## 가장 가까운 적이 있으면 그 자리를, 없으면 바라보는 방향으로 throw_range만큼 떨어진 지점을 조준.
func _pick_landing_point(data: WhitePhosphorusEggData) -> Vector2:
	var target := _find_nearest_enemy(data.throw_range)
	if target != null:
		return target.global_position
	var facing: Vector2 = owner_body.get("facing_direction")
	return owner_body.global_position + facing * data.throw_range

func _indicator_color() -> Color:
	return Color(0.85, 0.95, 0.6, 0.35)
