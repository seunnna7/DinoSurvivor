class_name HornBoomerangProjectile
extends BaseAttackObject
## '뿔메랑' 투사체 하나. base_projectile.gd의 direction*speed 이동 모델을 쓰지 않고 직접
## 상속(BaseAttackObject)한 이유는, 이 스킬이 "한 방향으로 쭉 날아간다"가 아니라 던진 자리에서
## 출발해 이차함수(포물선) 전진 + 사인 곡선의 좌우 흔들림을 합쳐 물방울(테어드롭) 모양을 그리며
## 다시 던진 자리로 돌아와 소멸하는, 형태 자체가 다른 궤적이기 때문입니다.
##
## 궤적 계산(진행률 t, 0~1, 왕복 1회 기준):
##   forward(t) = 4 * t * (1-t) * forward_range         -- 이차함수. 0에서 시작해 t=0.5에서 최대, 다시 0으로
##   lateral(t) = sin(PI * t) * lateral_amplitude * sign -- 0에서 시작해 부풀었다 다시 0으로
## 두 값을 조준 방향(전진 축)과 그 수직 방향(좌우 축)에 각각 실어 합치면, 던진 자리(t=0)에서
## 출발해 조준 방향으로 부풀어 오르듯 나갔다가 같은 자리(t=1)로 돌아오는 물방울 모양이 나옵니다.
## Lv3+(loop_count=2)는 두 번째 바퀴의 부풀림 방향을 반전시켜 8자 궤적을 만듭니다(설계서 6-1).
##
## 관통은 이 스킬의 기본 정체성이라 별도 플래그 없이 항상 켜져 있습니다 — 부모(BaseAttackObject)의
## 기본 _on_hit_enemy()가 이미 "데미지만 주고 소멸하지 않음"이라 오버라이드가 필요 없습니다.

@export var forward_range: float = 220.0
@export var lateral_amplitude: float = 90.0
@export var loop_duration: float = 0.45
@export var loop_count: int = 1
@export var spin_speed: float = 16.0  ## 라디안/초. 날아가는 동안 스프라이트가 제자리에서 회전하는 시각 효과(진행 방향과 무관)

var evolution: HornBoomerangData.Evolution = HornBoomerangData.Evolution.NONE
var wild_curve_scale_multiplier: float = 2.2
var wild_curve_spin_duration: float = 0.5
var wild_curve_tick_interval: float = 0.15
var wild_curve_radius: float = 60.0

var _origin: Vector2 = Vector2.ZERO
var _forward_axis: Vector2 = Vector2.RIGHT
var _lateral_axis: Vector2 = Vector2.DOWN
var _base_curve_sign: float = 1.0

var _elapsed: float = 0.0
var _current_loop: int = 0
var _is_finished: bool = false

## curve_sign: +1.0 / -1.0. 첫 바퀴가 어느 방향으로 부풀지 결정(형태 A는 좌/우로 서로 다르게 넘김).
func launch(from_position: Vector2, aim_dir: Vector2, curve_sign: float) -> void:
	_origin = from_position
	_forward_axis = aim_dir
	_lateral_axis = aim_dir.orthogonal()
	_base_curve_sign = curve_sign
	_update_position(0.0)

func _physics_process(delta: float) -> void:
	if _is_finished:
		return
	rotation += spin_speed * delta
	_elapsed += delta
	var t := clampf(_elapsed / loop_duration, 0.0, 1.0)
	_update_position(t)
	if t >= 1.0:
		_current_loop += 1
		if _current_loop >= loop_count:
			_on_finished()
		else:
			_elapsed = 0.0

## 짝수 번째(0, 2, ...) 바퀴는 기본 방향으로, 홀수 번째 바퀴는 반전된 방향으로 부풀어 8자를 그림.
func _current_curve_sign() -> float:
	return _base_curve_sign if _current_loop % 2 == 0 else -_base_curve_sign

func _update_position(t: float) -> void:
	var forward := 4.0 * t * (1.0 - t) * forward_range
	var lateral := sin(PI * t) * lateral_amplitude * _current_curve_sign()
	global_position = _origin + _forward_axis * forward + _lateral_axis * lateral

func _on_finished() -> void:
	_is_finished = true
	if evolution == HornBoomerangData.Evolution.WILD_CURVE:
		_play_wild_curve_finish()
	else:
		queue_free()

## 형태 B(광폭 곡선): 돌아온 자리에서 커지며 짧게 제자리 회전 타격을 반복한 뒤 소멸.
## 이 시점부터는 통과 판정(Area2D 겹침)이 아니라 _deal_aoe_damage()로 직접 반경을 때리므로
## monitoring을 꺼서 겹침 신호가 중복으로 섞이지 않게 함.
func _play_wild_curve_finish() -> void:
	monitoring = false
	var tween := create_tween()
	tween.tween_property(self, "scale", scale * wild_curve_scale_multiplier, 0.15)

	var ticks := maxi(1, roundi(wild_curve_spin_duration / wild_curve_tick_interval))
	for i in ticks:
		_deal_aoe_damage(global_position, wild_curve_radius, damage)
		await get_tree().create_timer(wild_curve_tick_interval).timeout
	queue_free()
