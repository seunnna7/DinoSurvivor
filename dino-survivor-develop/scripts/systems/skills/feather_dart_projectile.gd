class_name FeatherDartProjectile
extends BaseProjectile
## '깃털 다트' 투사체. 공통 이동/충돌 배관은 BaseProjectile이 처리하고,
## 여기서는 깃털 다트 고유의 3가지 상태만 다룹니다:
##   - pierce_enabled  : Lv3+ 부터, 경로상 스치는 모든 적에게 데미지 (그 전까지는 도착 지점 AOE로만 타격)
##   - is_cross_strike : 형태 A(조준타격). 사거리 절반 지점(cross_point)에서 1회, 도착 지점에서 1회,
##                        각각 AOE로 2배 데미지
##   - is_ricochet     : 형태 B(팅!). 화면 테두리에 부딪히면 Vector2.bounce()로 반사,
##                        최대 max_bounce_count회까지 튕기고 이후엔 그 자리에서 도착 지점과 동일하게 처리

@export var pierce_enabled: bool = false
@export var aoe_radius: float = 28.0

var is_cross_strike: bool = false
var cross_point: Vector2 = Vector2.ZERO
var cross_damage_multiplier: float = 2.0
var _cross_triggered: bool = false

var is_ricochet: bool = false
var max_bounce_count: int = 3
var _bounce_count: int = 0

func _on_travel(_delta: float) -> void:
	if is_cross_strike and not _cross_triggered and _traveled_distance >= max_distance * 0.5:
		_cross_triggered = true
		_deal_aoe_damage(cross_point, aoe_radius, damage * cross_damage_multiplier)
	if is_ricochet:
		_check_ricochet()

## 관통(Lv3+)이면 지나가는 적을 즉시 타격하되 소멸하지 않고 계속 비행합니다.
## 관통이 아니면(Lv1~2) 경로상 충돌은 완전히 무시하고, 최종 도착 지점 AOE로만 타격합니다.
func _on_hit_enemy(enemy: Enemy) -> void:
	if not pierce_enabled:
		return
	enemy.take_damage(damage, knockback_distance, global_position)

## 최종 도착 지점(사거리 소진) AOE. 형태 A(조준타격)는 도착 지점도 2배 데미지가 적용됩니다.
func _on_range_reached() -> void:
	var amount := damage * cross_damage_multiplier if is_cross_strike else damage
	_deal_aoe_damage(global_position, aoe_radius, amount)
	_despawn()

## 현재 카메라 기준 화면 테두리에 닿으면 Vector2.bounce()로 반사시킵니다.
## 최대 반사 횟수를 넘기면 그 자리에서 도착 지점과 동일하게 취급해 AOE를 터뜨리고 소멸합니다.
func _check_ricochet() -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var half_size: Vector2 = get_viewport().get_visible_rect().size / cam.zoom / 2.0
	var bounds := Rect2(cam.global_position - half_size, half_size * 2.0)
	var bounced := false

	if global_position.x <= bounds.position.x:
		global_position.x = bounds.position.x
		direction = direction.bounce(Vector2.RIGHT)
		bounced = true
	elif global_position.x >= bounds.end.x:
		global_position.x = bounds.end.x
		direction = direction.bounce(Vector2.LEFT)
		bounced = true

	if global_position.y <= bounds.position.y:
		global_position.y = bounds.position.y
		direction = direction.bounce(Vector2.DOWN)
		bounced = true
	elif global_position.y >= bounds.end.y:
		global_position.y = bounds.end.y
		direction = direction.bounce(Vector2.UP)
		bounced = true

	if not bounced:
		return
	rotation = direction.angle()
	_bounce_count += 1
	if _bounce_count > max_bounce_count:
		_on_range_reached()
