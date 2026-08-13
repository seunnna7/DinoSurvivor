class_name HornBoomerangSkill
extends BaseSkill
## '뿔메랑' 발사 로직. 가장 가까운 적 방향(없으면 바라보는 방향)으로 조준한 뒤, 진화 형태에 따라:
##   - 진화 전 / 형태 B(광폭 곡선): 뿔 1개를 던짐. 부풀어 오르는 방향(좌/우)은 매번 랜덤.
##   - 형태 A(이중 뿔메랑): 뿔 2개를 동시에 던지되, 서로 반대 방향으로 부풀도록 curve_sign을
##     반전시켜 커버리지를 좌우로 넓힘.
## 왕복 횟수(Lv3부터 8자 궤적)와 진화별 마무리 동작(광폭 곡선의 확대+회전 타격)은
## HornBoomerangProjectile이 전담하므로, 여기서는 "몇 개를, 어느 방향으로 던질지"만 결정합니다.

const PROJECTILE_SCENE := preload("res://scenes/skills/HornBoomerangProjectile.tscn")
const SEARCH_RANGE := 500.0

func _fire() -> void:
	var hdata := skill_data as HornBoomerangData
	var target := _find_nearest_enemy(SEARCH_RANGE)
	var aim_dir: Vector2
	if target != null:
		aim_dir = owner_body.global_position.direction_to(target.global_position)
	else:
		aim_dir = owner_body.get("facing_direction")
	if aim_dir == Vector2.ZERO:
		aim_dir = Vector2.RIGHT
	aim_dir = aim_dir.normalized()

	if hdata.evolution == HornBoomerangData.Evolution.TWIN:
		_spawn_boomerang(aim_dir, hdata, 1.0)
		_spawn_boomerang(aim_dir, hdata, -1.0)
	else:
		var curve_sign := 1.0 if randf() < 0.5 else -1.0
		_spawn_boomerang(aim_dir, hdata, curve_sign)

func _spawn_boomerang(aim_dir: Vector2, hdata: HornBoomerangData, curve_sign: float) -> void:
	var boomerang: HornBoomerangProjectile = PROJECTILE_SCENE.instantiate()
	owner_body.get_parent().add_child(boomerang)
	boomerang.damage = _leveled_damage()
	boomerang.knockback_distance = hdata.knockback_distance
	boomerang.forward_range = hdata.forward_range
	boomerang.lateral_amplitude = hdata.lateral_amplitude
	boomerang.loop_duration = hdata.loop_duration
	boomerang.loop_count = hdata.loop_count_for_level(level)
	boomerang.evolution = hdata.evolution
	boomerang.wild_curve_scale_multiplier = hdata.wild_curve_scale_multiplier
	boomerang.wild_curve_spin_duration = hdata.wild_curve_spin_duration
	boomerang.wild_curve_tick_interval = hdata.wild_curve_tick_interval
	boomerang.wild_curve_radius = hdata.wild_curve_radius
	boomerang.launch(owner_body.global_position, aim_dir, curve_sign)

func _indicator_color() -> Color:
	return Color(0.85, 0.6, 0.2, 0.35)
