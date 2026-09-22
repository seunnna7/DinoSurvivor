class_name WhitePhosphorusEggProjectile
extends BaseLobbedProjectile
## 백린란 투사체. 착탄 시 부모(BaseLobbedProjectile)의 기본 동작(반경 aoe_radius 즉시 폭발)은
## 그대로 두고, 그 위에 VenomSpitZone(침 뱉기 장판)을 하나 더 남깁니다 — 새 장판 클래스를
## 만들 필요 없이 기존 지속 DOT 장판을 그대로 재사용(슬로우는 주지 않으므로 slow_multiplier는
## 기본값 1.0 그대로 둠).

const ZONE_SCENE := preload("res://scenes/skills/VenomSpitZone.tscn")

var zone_radius: float = 100.0
var zone_duration: float = 5.0
var tick_interval: float = 0.5
var zone_damage: float = 0.0

func _on_landed() -> void:
	var zone: VenomSpitZone = ZONE_SCENE.instantiate()
	zone.global_position = global_position
	zone.damage = zone_damage
	zone.knockback_distance = 0.0
	zone.radius = zone_radius
	zone.duration = zone_duration
	zone.tick_interval = tick_interval
	get_parent().add_child(zone)
	super._on_landed()  # 반경 aoe_radius 즉시 폭발 데미지 + queue_free()
