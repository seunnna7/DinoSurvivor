extends SkillInstanceBase
## 물기 (기획서 4.2: 근접/흡입형, 티라노 고유 액티브)
## 사거리 내 가장 가까운 몹 하나를 찾아 데미지를 입힙니다.
## 지금은 즉시 데미지만 처리. "흡입" 연출(끌어당기기)은 이후 폴리싱 단계에서 추가 예정.

const RANGE := 30.0

func setup(data: SkillData, body: Node2D) -> void:
	super.setup(data, body)
	_show_range_indicator(RANGE, Color(1.0, 0.9, 0.2, 0.35))

func _perform() -> void:
	var target := _find_nearest_enemy()
	if target != null:
		target.take_damage(_leveled_damage())
		_spawn_hit_effect(target.global_position)

func _spawn_hit_effect(pos: Vector2) -> void:
	if skill_data.effect_scene == null:
		return
	var effect: Node2D = skill_data.effect_scene.instantiate()
	owner_body.get_parent().add_child(effect)
	effect.global_position = pos

func _find_nearest_enemy() -> Enemy:
	var nearest: Enemy = null
	var nearest_dist := RANGE
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy := node as Enemy
		if enemy == null:
			continue
		var dist := owner_body.global_position.distance_to(enemy.global_position)
		if dist <= nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest
