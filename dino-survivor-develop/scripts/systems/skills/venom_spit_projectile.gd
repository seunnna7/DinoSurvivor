class_name VenomSpitProjectile
extends BaseLobbedProjectile
## 침 뱉기 투사체. 착탄 시 부모(BaseLobbedProjectile)처럼 즉시 폭발 데미지를 주는 대신,
## 그 자리에 VenomSpitZone(중독 장판, BaseAreaEffect 기반)을 남깁니다 — 알 폭탄과 달리
## "즉발 폭발 없는 지속 장판형 DOT"이라는 설계서 4-3의 컨셉을 그대로 반영.
## 진화 A(맹독지대)는 장판 반경만 키우고 감속 수치를 채워 넘기는 순수 데이터 차이라 코드 분기가 거의 없음.

const ZONE_SCENE := preload("res://scenes/skills/VenomSpitZone.tscn")

var zone_duration: float = 3.0
var tick_interval: float = 0.5
var evolution: VenomSpitData.Evolution = VenomSpitData.Evolution.NONE
var toxic_field_radius_multiplier: float = 1.8
var toxic_field_slow_multiplier: float = 0.5
var toxic_field_slow_duration: float = 1.0

func _on_landed() -> void:
	var zone: VenomSpitZone = ZONE_SCENE.instantiate()
	zone.global_position = global_position
	zone.damage = damage
	zone.knockback_distance = knockback_distance
	zone.radius = _effective_radius()
	zone.duration = zone_duration
	zone.tick_interval = tick_interval
	if evolution == VenomSpitData.Evolution.TOXIC_FIELD:
		zone.slow_multiplier = toxic_field_slow_multiplier
		zone.slow_duration = toxic_field_slow_duration
	get_parent().add_child(zone)
	queue_free()

## 착탄 예정 지점 표시도 실제로 남을 장판 크기와 일치해야 하므로(진화 A는 더 크게), 부모의
## 기본 표시 대신 _effective_radius()로 계산한 반경을 사용.
func _show_landing_indicators() -> void:
	_add_landing_indicator(target, _effective_radius())

func _effective_radius() -> float:
	if evolution == VenomSpitData.Evolution.TOXIC_FIELD:
		return aoe_radius * toxic_field_radius_multiplier
	return aoe_radius
