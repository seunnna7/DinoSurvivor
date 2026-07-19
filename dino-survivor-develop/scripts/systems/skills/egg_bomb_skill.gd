class_name EggBombSkill
extends BaseSkill
## 알 폭탄: 가장 가까운 적의 위치(없으면 바라보는 방향으로 throw_range만큼 떨어진 지점)를
## 목표로 알을 포물선으로 던집니다. 실제 이동/착탄 판정은 BaseLobbedProjectile을 상속한
## EggBombProjectile이 전담하므로, 여기서는 "어디로 던질지"와 "던질 알의 수치 세팅"만 합니다.

const PROJECTILE_SCENE := preload("res://scenes/skills/EggBombProjectile.tscn")

func setup(data: SkillData, body: Node2D) -> void:
	super.setup(data, body)
	_show_range_indicator((data as EggBombData).throw_range, _indicator_color())

func _fire() -> void:
	var data := skill_data as EggBombData
	var landing_point := _pick_landing_point(data)

	var egg: EggBombProjectile = PROJECTILE_SCENE.instantiate()
	egg.damage = _leveled_damage()
	egg.flight_time = data.flight_time
	egg.aoe_radius = data.aoe_radius_for_level(level)
	egg.evolution = data.evolution
	egg.mine_count = data.mine_count
	egg.mine_scatter_radius = data.mine_scatter_radius
	egg.mine_radius = data.mine_radius
	egg.mine_lifetime = data.mine_lifetime
	owner_body.get_parent().add_child(egg)
	egg.launch(owner_body.global_position, landing_point)

## 가장 가까운 적이 있으면 그 자리를, 없으면 바라보는 방향으로 throw_range만큼 떨어진 지점을 조준.
func _pick_landing_point(data: EggBombData) -> Vector2:
	var target := _find_nearest_enemy(data.throw_range)
	if target != null:
		return target.global_position
	var facing: Vector2 = owner_body.get("facing_direction")
	return owner_body.global_position + facing * data.throw_range

func _indicator_color() -> Color:
	return Color(0.95, 0.85, 0.6, 0.35)
