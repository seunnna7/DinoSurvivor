extends SkillInstanceBase
## 철퇴 (광역 후려치기): 플레이어가 바라보는 방향 기준 부채꼴(ARC_DEGREES) 범위의 적을 타격.
## 사거리 표시와 타격 판정 모두 실시간 플레이어 위치/방향(owner_body.facing_direction)을 기준으로 삼습니다.

const RANGE := 90.0
const ARC_DEGREES := 90.0
const DELAY := 0.4

func setup(data: SkillData, body: Node2D) -> void:
	super.setup(data, body)
	_show_range_indicator(RANGE, Color(1.0, 0.55, 0.1, 0.35), ARC_DEGREES)

func _perform() -> void:
	await get_tree().create_timer(DELAY).timeout
	var origin := owner_body.global_position
	var facing: Vector2 = owner_body.get("facing_direction")
	_spawn_impact_effect(facing)
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy := node as Enemy
		if enemy == null:
			continue
		if _is_in_arc(origin, facing, enemy.global_position):
			enemy.take_damage(_leveled_damage())

func _is_in_arc(origin: Vector2, facing: Vector2, target_pos: Vector2) -> bool:
	if origin.distance_to(target_pos) > RANGE:
		return false
	var to_target := target_pos - origin
	if to_target.length() < 0.001:
		return true
	return abs(facing.angle_to(to_target)) <= deg_to_rad(ARC_DEGREES) / 2.0

func _spawn_impact_effect(facing: Vector2) -> void:
	if skill_data.effect_scene == null:
		return
	var effect: MaceImpactEffect = skill_data.effect_scene.instantiate()
	effect.length = RANGE
	effect.arc_degrees = ARC_DEGREES
	effect.facing_angle = facing.angle()
	owner_body.add_child(effect)
