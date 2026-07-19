class_name MaceSkill
extends BaseMeleeSkill
## 철퇴 (광역 후려치기): 기본형/형태 A(전방향)는 플레이어 기준 부채꼴(또는 360도) 범위를
## 휘둘러 적을 전부 타격 + 넉백. 선딜레이/각도 판정/전체 대상 타격/데미지는 전부
## BaseMeleeSkill + MeleeSkillData가 처리하므로, 여기서는 잔상 이펙트 스폰과 넉백만 추가합니다.
##
## 형태 B(내려찍기)는 "휘두르기"라는 틀 자체를 벗어나(부채꼴이 아니라 지면 한 점을 내려찍는
## 원형 AOE) BaseMeleeSkill의 arc 판정 흐름과 안 맞기 때문에, _fire()를 오버라이드해서
## 그 경우에만 별도 충격파 오브젝트(MaceSlamImpact)를 스폰하는 식으로 분기합니다.

const SLAM_SCENE := preload("res://scenes/skills/MaceSlamImpact.tscn")

func _fire() -> void:
	var data := _melee_data() as MaceSkillData
	if data.evolution == MaceSkillData.Evolution.SLAM:
		_fire_slam(data)
	else:
		super._fire()  # 기본형 / 형태 A(전방향 휘두르기) — 부채꼴·전방위 판정은 데이터가 이미 표현함

## 판정 직전(hit_delay가 끝난 시점) 1회 호출. facing 방향으로 부채꼴 잔상 이펙트를 스폰.
func _on_swing(facing: Vector2) -> void:
	if skill_data.effect_scene == null:
		return
	var melee_data := _melee_data()
	var effect: MaceImpactEffect = skill_data.effect_scene.instantiate()
	effect.length = melee_data.range_for_level(level)
	effect.arc_degrees = melee_data.arc_degrees_for_level(level)
	effect.facing_angle = facing.angle()
	owner_body.add_child(effect)

## 실제로 맞은 적마다 호출(기본형/형태 A 공통) — 철퇴다운 넉백을 여기서 부여.
func _on_hit(enemy: Enemy) -> void:
	var data := _melee_data() as MaceSkillData
	var kb_dir := owner_body.global_position.direction_to(enemy.global_position)
	if kb_dir == Vector2.ZERO:
		kb_dir = Vector2.RIGHT
	enemy.apply_knockback(kb_dir, data.knockback_force, data.knockback_duration)

## 형태 B(내려찍기): 가장 가까운 적의 위치(없으면 바라보는 방향의 사거리 지점)를 내려찍어
## 원형 AOE 폭발 + 강한 넉백을 주는 충격파 오브젝트를 스폰합니다.
func _fire_slam(data: MaceSkillData) -> void:
	var slam_range := data.range_for_level(level)
	var target := _find_nearest_enemy(slam_range)
	var slam_pos := owner_body.global_position + _current_facing() * slam_range * 0.6
	if target != null:
		slam_pos = target.global_position

	# 주의: BaseAreaEffect는 _ready()에서 곧바로 스폰 지점을 스캔해 데미지를 적용하므로,
	# add_child()로 트리에 들어가 _ready()가 실행되기 전에 위치/수치를 전부 먼저 채워야 함.
	var slam: MaceSlamImpact = SLAM_SCENE.instantiate()
	slam.global_position = slam_pos
	slam.damage = _leveled_damage()
	slam.radius = data.slam_radius
	slam.knockback_force = data.slam_knockback_force
	slam.knockback_duration = data.knockback_duration
	owner_body.get_parent().add_child(slam)

func _indicator_color() -> Color:
	return Color(1.0, 0.55, 0.1, 0.35)
