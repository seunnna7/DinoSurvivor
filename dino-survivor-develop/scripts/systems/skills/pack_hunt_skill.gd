class_name PackHuntSkill
extends BaseSkill
## 무리 사냥: 발동할 때마다 플레이어 주변 임의의 위치(들)에 발톱 할퀴기를 소환합니다.
##   - 기본형 / 진화 A(비열한 협공): ClawSwipeArea를 레벨에 따라 여러 개(strike_count) 랜덤 소환.
##     차이는 순수 데이터 — 진화 A는 tick_interval/bleed 필드를 채워서 다단히트+출혈로 만듦.
##   - 진화 B(공격명령): 랜덤 소환 대신, 가장 가까운 적을 향해 서서히 이동하는 거대한 영역 하나를
##     소환. BaseAreaEffect가 move_speed/tick_interval을 이미 지원하므로 별도 스크립트 없이
##     HuntingZone.tscn(순정 base_area_effect.gd)을 그대로 씀 — 새 코드가 필요 없는 케이스.

const CLAW_SCENE := preload("res://scenes/skills/ClawSwipeArea.tscn")
const ZONE_SCENE := preload("res://scenes/skills/HuntingZone.tscn")

func setup(data: SkillData, body: Node2D) -> void:
	super.setup(data, body)
	_show_range_indicator((data as PackHuntData).spawn_radius_around_player, _indicator_color())

func _fire() -> void:
	var data := skill_data as PackHuntData
	if data.evolution == PackHuntData.Evolution.HUNTING_ZONE:
		_spawn_hunting_zone(data)
	else:
		_spawn_claw_strikes(data)

## 기본형 / 진화 A: 레벨에 맞는 개수만큼 랜덤 위치에 발톱 자국을 동시에 소환.
func _spawn_claw_strikes(data: PackHuntData) -> void:
	var strike_count := data.strike_count_for_level(level)
	for i in strike_count:
		# 주의: BaseAreaEffect는 _ready()에서 곧바로 스폰 지점을 스캔해 데미지를 적용하므로,
		# add_child()로 트리에 들어가기 전에 위치/수치를 전부 먼저 채워야 함.
		var claw: ClawSwipeArea = CLAW_SCENE.instantiate()
		claw.global_position = _random_position_near_player(data.spawn_radius_around_player)
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

## 진화 B: 랜덤 위치 하나에 추적형 지속 영역을 소환.
func _spawn_hunting_zone(data: PackHuntData) -> void:
	var zone: BaseAreaEffect = ZONE_SCENE.instantiate()
	zone.global_position = _random_position_near_player(data.spawn_radius_around_player)
	zone.damage = _leveled_damage()
	zone.knockback_distance = data.knockback_distance
	zone.radius = data.zone_radius
	zone.duration = data.zone_duration
	zone.move_speed = data.zone_move_speed
	zone.tick_interval = data.zone_tick_interval
	owner_body.get_parent().add_child(zone)

func _random_position_near_player(radius: float) -> Vector2:
	var angle := randf() * TAU
	var dist := randf() * radius
	return owner_body.global_position + Vector2.RIGHT.rotated(angle) * dist

func _indicator_color() -> Color:
	return Color(0.75, 0.25, 0.25, 0.25)
