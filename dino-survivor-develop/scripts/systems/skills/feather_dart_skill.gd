class_name FeatherDartSkill
extends BaseSkill
## '깃털 다트' 발사 로직. 레벨/진화 상태에 따라:
##   - 진화 전(Lv1~5) 또는 형태 B(팅!): 가장 가까운 적 방향으로 다트 1개 발사
##   - 형태 A(조준타격): 좌/우 어깨 위치에서 서로 반대편을 향해 다트 2개를 발사해 X자로 교차시킴
## 사거리/관통/AOE 반경 등 수치는 전부 FeatherDartData에서 읽어옵니다.

const PROJECTILE_SCENE := preload("res://scenes/skills/FeatherDartProjectile.tscn")
const DART_SPEED := 500.0
const SEARCH_RANGE := 500.0  ## 조준 대상(가장 가까운 적) 탐색 반경. 다트 자체 사거리와는 별개

func _fire() -> void:
	var fdata := skill_data as FeatherDartData
	var target := _find_nearest_enemy(SEARCH_RANGE)
	if target == null:
		return
	var aim_dir := owner_body.global_position.direction_to(target.global_position)
	if aim_dir == Vector2.ZERO:
		aim_dir = Vector2.RIGHT

	if fdata.evolution == FeatherDartData.Evolution.CROSS_STRIKE:
		_fire_cross_strike(fdata, aim_dir)
	else:
		_fire_single(fdata, aim_dir)

## 기본 발사(진화 전) 및 형태 B(팅!): 다트 1개를 조준 방향으로 발사.
func _fire_single(fdata: FeatherDartData, aim_dir: Vector2) -> void:
	var dart := _spawn_dart(owner_body.global_position, aim_dir, fdata)
	if fdata.evolution == FeatherDartData.Evolution.RICOCHET:
		dart.is_ricochet = true
		dart.max_bounce_count = fdata.max_bounce_count

## 형태 A(조준타격): 좌/우 어깨에서 서로 반대편(교차 대상)을 향해 발사해 사거리 절반 지점에서 X자로
## 교차시킵니다. 두 발사선이 중심선을 기준으로 좌우 대칭이라, 진행률 t=0.5 지점에서 좌우 성분이
## 정확히 0이 되어(=중심선 위) 서로 만난다는 사실이 기하학적으로 보장되므로, 런타임에 두 투사체
## 사이 거리를 매 프레임 비교할 필요 없이 스폰 시점에 교차점을 계산해 그대로 넘겨줍니다.
func _fire_cross_strike(fdata: FeatherDartData, aim_dir: Vector2) -> void:
	var dart_range := fdata.range_for_level(level)
	var origin := owner_body.global_position
	var perp := aim_dir.orthogonal()
	var left_origin := origin - perp * fdata.shoulder_offset
	var right_origin := origin + perp * fdata.shoulder_offset
	var left_dest := origin + aim_dir * dart_range + perp * fdata.shoulder_offset
	var right_dest := origin + aim_dir * dart_range - perp * fdata.shoulder_offset
	var cross_point := origin + aim_dir * (dart_range * 0.5)

	var left_dart := _spawn_dart(left_origin, (left_dest - left_origin).normalized(), fdata)
	left_dart.is_cross_strike = true
	left_dart.cross_point = cross_point
	left_dart.cross_damage_multiplier = fdata.cross_damage_multiplier

	var right_dart := _spawn_dart(right_origin, (right_dest - right_origin).normalized(), fdata)
	right_dart.is_cross_strike = true
	right_dart.cross_point = cross_point
	right_dart.cross_damage_multiplier = fdata.cross_damage_multiplier

## 공통 스폰 로직: 투사체 인스턴스를 만들고 레벨 기반 공용 수치(데미지/사거리/관통/AOE)를 채운 뒤 발사.
func _spawn_dart(from_position: Vector2, aim_dir: Vector2, fdata: FeatherDartData) -> FeatherDartProjectile:
	var dart: FeatherDartProjectile = PROJECTILE_SCENE.instantiate()
	owner_body.get_parent().add_child(dart)
	dart.damage = _leveled_damage()
	dart.speed = DART_SPEED
	dart.max_distance = fdata.range_for_level(level)
	dart.pierce_enabled = fdata.pierce_for_level(level)
	dart.aoe_radius = fdata.aoe_radius
	dart.launch(from_position, aim_dir)
	return dart
