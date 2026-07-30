class_name PackHuntSkill
extends BaseSkill
## 무리 사냥: 발동할 때마다 플레이어 화면(카메라 가시 영역) 안에서 적이 가장 밀집된 지점에
## 발톱 할퀴기를 소환합니다. 별도의 고정 발동 범위가 없고, 화면 전체가 곧 탐색 범위입니다 —
## 진화 A/B도 동일하게 이 밀집 지점을 기준으로 소환됩니다.
##   - 기본형 / 진화 A(비열한 협공): ClawSwipeArea를 레벨에 따라 여러 개(strike_count) 밀집 지점
##     주변에 소폭 흩뿌려 소환. 차이는 순수 데이터 — 진화 A는 tick_interval/bleed 필드를 채워서
##     다단히트+출혈로 만듦.
##   - 진화 B(공격명령): 흩뿌리는 대신, 밀집 지점에 서서히 가장 가까운 적을 향해 이동하는 거대한
##     영역 하나를 소환. BaseAreaEffect가 move_speed/tick_interval을 이미 지원하므로 별도 스크립트
##     없이 HuntingZone.tscn(순정 base_area_effect.gd)을 그대로 씀 — 새 코드가 필요 없는 케이스.

const CLAW_SCENE := preload("res://scenes/skills/ClawSwipeArea.tscn")
const ZONE_SCENE := preload("res://scenes/skills/HuntingZone.tscn")
const CLUSTER_SEARCH_RADIUS := 120.0  ## 이 반경 안에 함께 있는 적의 수로 "밀집도"를 판정

func _fire() -> void:
	var data := skill_data as PackHuntData
	var target_point := _densest_enemy_cluster_point()
	if data.evolution == PackHuntData.Evolution.HUNTING_ZONE:
		_spawn_hunting_zone(data, target_point)
	else:
		_spawn_claw_strikes(data, target_point)

## 기본형 / 진화 A: 레벨에 맞는 개수만큼 밀집 지점 주변에 발톱 자국을 동시에 소환.
func _spawn_claw_strikes(data: PackHuntData, target_point: Vector2) -> void:
	var strike_count := data.strike_count_for_level(level)
	for i in strike_count:
		# 주의: BaseAreaEffect는 _ready()에서 곧바로 스폰 지점을 스캔해 데미지를 적용하므로,
		# add_child()로 트리에 들어가기 전에 위치/수치를 전부 먼저 채워야 함.
		var claw: ClawSwipeArea = CLAW_SCENE.instantiate()
		claw.global_position = _jitter_around(target_point, data.strike_spread_radius)
		claw.damage = _leveled_damage()
		claw.knockback_distance = data.knockback_distance
		claw.radius = data.radius_for_level(level)
		if data.evolution == PackHuntData.Evolution.BLEED_MULTI:
			claw.tick_interval = data.multi_hit_tick_interval
			claw.duration = data.multi_hit_duration
			claw.bleed_damage_per_second = data.bleed_damage_per_second
			claw.bleed_duration = data.bleed_duration
		else:
			claw.duration = data.fade_duration
		owner_body.get_parent().add_child(claw)

## 진화 B: 밀집 지점 하나에 추적형 지속 영역을 소환.
func _spawn_hunting_zone(data: PackHuntData, target_point: Vector2) -> void:
	var zone: BaseAreaEffect = ZONE_SCENE.instantiate()
	zone.global_position = target_point
	zone.damage = _leveled_damage()
	zone.knockback_distance = data.knockback_distance
	zone.radius = data.zone_radius
	zone.duration = data.zone_duration
	zone.move_speed = data.zone_move_speed
	zone.tick_interval = data.zone_tick_interval
	owner_body.get_parent().add_child(zone)

## 카메라 가시 영역(화면) 안에 있는 적들 중, CLUSTER_SEARCH_RADIUS 안에 가장 많은 적이 몰려 있는
## 적의 위치를 찾습니다. 화면 안에 적이 하나도 없으면 플레이어 위치를 그대로 반환합니다.
func _densest_enemy_cluster_point() -> Vector2:
	var visible_rect := _visible_world_rect()
	var enemies_on_screen: Array[Enemy] = []
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy := node as Enemy
		if enemy != null and visible_rect.has_point(enemy.global_position):
			enemies_on_screen.append(enemy)
	if enemies_on_screen.is_empty():
		return owner_body.global_position

	var best_position := enemies_on_screen[0].global_position
	var best_count := -1
	for candidate in enemies_on_screen:
		var count := 0
		for other in enemies_on_screen:
			if candidate.global_position.distance_to(other.global_position) <= CLUSTER_SEARCH_RADIUS:
				count += 1
		if count > best_count:
			best_count = count
			best_position = candidate.global_position
	return best_position

## 현재 활성 카메라 기준, 플레이어 화면에 실제로 보이는 월드 좌표 사각형.
func _visible_world_rect() -> Rect2:
	var viewport := owner_body.get_viewport()
	var screen_size := viewport.get_visible_rect().size
	var camera := viewport.get_camera_2d()
	if camera == null:
		return Rect2(owner_body.global_position - screen_size * 0.5, screen_size)
	var world_size := screen_size / camera.zoom
	return Rect2(camera.get_screen_center_position() - world_size * 0.5, world_size)

## 같은 지점에 동시 소환되는 여러 발톱 자국이 완전히 겹치지 않도록 소폭 흩뿌림.
func _jitter_around(point: Vector2, spread_radius: float) -> Vector2:
	if spread_radius <= 0.0:
		return point
	var angle := randf() * TAU
	var dist := randf() * spread_radius
	return point + Vector2.RIGHT.rotated(angle) * dist
