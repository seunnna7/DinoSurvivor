class_name FeatherDartProjectile
extends BaseProjectile
## '깃털 다트' 투사체. 공통 이동/충돌 배관은 BaseProjectile이 처리하고,
## 여기서는 깃털 다트 고유의 3가지 상태만 다룹니다:
##   - pierce_enabled  : Lv3+ 부터, 경로상 스치는 모든 적에게 데미지하며 계속 비행
##                        (그 전까지는 경로상 처음 부딪힌 적의 위치에서 즉시 도착 처리)
##   - is_cross_strike : 형태 A(조준타격). 사거리 절반 지점(cross_point)에서 1회, 도착 지점에서 1회,
##                        각각 AOE로 2배 데미지
##   - is_ricochet     : 형태 B(팅!). 화면 테두리에 부딪히면 Vector2.bounce()로 반사,
##                        최대 max_bounce_count회까지 튕기고 이후엔 그 자리에서 도착 지점과 동일하게 처리

@export var pierce_enabled: bool = false
@export var aoe_radius: float = 28.0
@export var stuck_hold_duration: float = 0.3 ## 땅에 박힌 채 완전히 보이는 시간
@export var stuck_fade_duration: float = 0.4 ## 이후 서서히 사라지는 시간
@export var stuck_wobble_degrees: float = 20.0 ## 박히는 순간 관성으로 더 꺾이는 각도 범위(좌우 랜덤)
@export var stuck_wobble_duration: float = 0.1 ## 위 회전이 일어나는 시간(짧고 튕기듯)
@export var max_stuck_tilt_degrees: float = 70.0 ## 박힐 때 깃털(뿌리) 쪽이 수직 위 기준 벗어날 수 있는 최대 각도

var is_cross_strike: bool = false
var cross_point: Vector2 = Vector2.ZERO
var cross_damage_multiplier: float = 2.0
var _cross_triggered: bool = false

var is_ricochet: bool = false
var max_bounce_count: int = 3
var _bounce_count: int = 0

## Godot 각도 기준(0=+X, +는 화면 기준 시계방향) "화면 아래쪽"에 해당하는 값.
## 진행 방향(팁)이 아래쪽이면 깃털(뿌리, 진행 방향의 반대)은 저절로 위쪽 — 이게 클램프가
## 필요 없는 "기준" 자세라, 팁 회전값을 이 각도 기준으로 바로 비교/클램프하면 된다.
const DOWN_ANGLE := PI / 2.0

var _stuck_pivot_global: Vector2 = Vector2.ZERO  ## 꺾임 애니메이션 동안 고정할 "깃털 끝" 월드 좌표
var _stuck_pivot_distance: float = 0.0            ## 스프라이트 중심 → 깃털 끝까지, 로컬 +X(진행 방향) 기준 거리

func _on_travel(_delta: float) -> void:
	if is_cross_strike and not _cross_triggered and _traveled_distance >= max_distance * 0.5:
		_cross_triggered = true
		_deal_aoe_damage(cross_point, aoe_radius, damage * cross_damage_multiplier)
	if is_ricochet:
		_check_ricochet()

## 관통(Lv3+)이면 지나가는 적을 즉시 타격하되 소멸하지 않고 계속 비행합니다.
## 관통이 아니면(Lv1~2) 경로상 처음 부딪힌 적의 위치에서 바로 도착 처리(AOE + 박힘)합니다.
func _on_hit_enemy(enemy: Enemy) -> void:
	if not pierce_enabled:
		_on_range_reached()
		return
	enemy.take_damage(damage, knockback_distance, global_position)

## 최종 도착 지점(사거리 소진) AOE. 형태 A(조준타격)는 도착 지점도 2배 데미지가 적용됩니다.
func _on_range_reached() -> void:
	var amount := damage * cross_damage_multiplier if is_cross_strike else damage
	_deal_aoe_damage(global_position, aoe_radius, amount)
	_stick_and_fade()

## 사거리를 다 쓰면 그 자리에서 바로 사라지는 대신, 잠깐 땅에 박힌 채로 멈췄다가 서서히
## 페이드아웃합니다. _is_expired를 즉시 켜서 이동/충돌은 그대로 멈추고, 시각적 소멸만 늦춥니다.
## 박히는 순간 관성으로 살짝 더 꺾이는(TRANS_BACK로 오버슈트 후 정착) 회전을 먼저 재생하되,
## 회전축은 스프라이트 중심이 아니라 실제로 땅에 박힌 지점인 "깃털 끝"이어야 합니다.
func _stick_and_fade() -> void:
	_is_expired = true
	_stuck_pivot_distance = _tip_offset_distance()
	var base_rotation := rotation
	_stuck_pivot_global = global_position + Vector2(_stuck_pivot_distance, 0.0).rotated(base_rotation)
	var target_rotation := _clamp_stuck_rotation(base_rotation)
	var wobble := deg_to_rad(randf_range(-stuck_wobble_degrees, stuck_wobble_degrees))

	var tween := create_tween()
	tween.tween_method(_set_rotation_around_tip, base_rotation, target_rotation + wobble, stuck_wobble_duration) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(stuck_hold_duration)
	tween.tween_property(self, "modulate:a", 0.0, stuck_fade_duration)
	tween.tween_callback(queue_free)

## 발사각과 무관하게, 박힌 뒤에는 깃털(뿌리) 쪽이 항상 수직 위 기준 ±max_stuck_tilt_degrees
## 안에 들어오도록 tip_rotation(현재 진행 방향 각도)을 보정합니다. "뿌리가 위쪽"은 곧 "팁이
## 아래쪽"과 같은 말이므로, DOWN_ANGLE 기준으로 팁 회전값을 직접 클램프하면 됩니다 — 팁이
## 정반대인 위쪽을 향하는 극단적인 경우(다트가 수직으로 날아간 경우)는 DOWN_ANGLE 기준으로
## 봤을 때 편차가 180도인 경우와 같아서, 별도 분기 없이 같은 계산식으로 처리됩니다.
func _clamp_stuck_rotation(tip_rotation: float) -> float:
	var deviation_from_down := angle_difference(DOWN_ANGLE, tip_rotation)
	var max_deviation := deg_to_rad(max_stuck_tilt_degrees)
	var clamped_deviation := clampf(deviation_from_down, -max_deviation, max_deviation)
	return DOWN_ANGLE + clamped_deviation

## Sprite2D는 중앙 정렬(centered)이라, 텍스처 절반 폭에 스케일을 곱하면 로컬 +X(진행 방향) 쪽
## 가장자리 = 깃털 끝까지의 거리가 됩니다.
func _tip_offset_distance() -> float:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null or sprite.texture == null:
		return 0.0
	return sprite.texture.get_size().x * 0.5 * sprite.scale.x

## rotation을 바꾸되, 깃털 끝(_stuck_pivot_global)은 제자리에 고정되도록 global_position을
## 매 스텝 함께 보정합니다 — 그냥 self.rotation만 바꾸면 스프라이트 중심을 축으로 돌아버립니다.
func _set_rotation_around_tip(angle: float) -> void:
	rotation = angle
	global_position = _stuck_pivot_global - Vector2(_stuck_pivot_distance, 0.0).rotated(angle)

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
