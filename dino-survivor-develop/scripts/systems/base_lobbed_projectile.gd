class_name BaseLobbedProjectile
extends BaseAttackObject
## 곡사형(포물선) 공격 오브젝트의 공통 로직. 출발지에서 목표 지점까지 flight_time 동안
## 이동하며, 비행 중에는 아무것도 타격하지 않다가(monitoring을 꺼서 충돌 자체를 무시) 도착하면
## _on_landed()를 호출합니다. 기본 구현은 반경 aoe_radius 안의 적에게 즉시 폭발 데미지.
##
## "포물선"의 시각적 표현: 카메라는 순수 탑다운이라 실제 Z축 낙하는 없으므로, 게임플레이 좌표
## (global_position/rotation, _deal_aoe_damage 기준점, 착탄 인디케이터)는 출발점→목표점 직선
## 보간(lerp)을 그대로 쓰는 "바닥 진실값"으로 유지합니다. 그 위에 쿼터뷰 정도의 높이감을 얹기
## 위해, 자식 노드 Visual(스프라이트 등 실제 그림)을 화면 스페이스로 들어올렸다 내리고
## (position.y), 동시에 Shadow(바닥 고정)를 살짝 작아지고 옅어지게 해서 "떠 있다"는 걸
## 보여줍니다. 이 두 자식 노드의 트랜스폼은 순수 시각 연출이라 충돌/데미지 판정과 무관합니다.

@export var flight_time: float = 0.6
@export var aoe_radius: float = 50.0
@export var peak_scale: float = 1.6  ## 비행 정점(t=0.5)에서 Visual이 커지는 배율
@export var arc_height_px: float = 40.0  ## 비행 정점에서 Visual이 화면상 위로 들리는 픽셀 거리(쿼터뷰 강도)

@onready var _visual: Node2D = $Visual
@onready var _shadow: LobbedShadow = $Shadow

var origin: Vector2 = Vector2.ZERO
var target: Vector2 = Vector2.ZERO

var _elapsed: float = 0.0
var _landed: bool = false
var _landing_indicators: Array[SkillRangeIndicator] = []

## distance/max_distance 비율(0~1)만큼 min_time~max_time 사이를 선형 보간. 스킬 스크립트가
## "이번엔 얼마나 멀리 던지나"를 알고 있을 때, launch() 전에 flight_time을 미리 계산해 넣는 용도
## (거리에 비례하되 너무 짧거나 길어지지 않게 min/max로 캡). 예: EggBombSkill._fire(), VenomSpitSkill._fire().
static func flight_time_for_distance(distance: float, max_distance: float, min_time: float, max_time: float) -> float:
	if max_distance <= 0.0:
		return min_time
	return lerpf(min_time, max_time, clampf(distance / max_distance, 0.0, 1.0))

func _ready() -> void:
	super._ready()
	monitoring = false  # 비행 중에는 아무것도 타격하지 않음 — 착탄 시에만 _on_landed()로 폭발 판정

## 스폰 직후 호출. 출발지/목표 착탄 지점을 설정하고, 착탄 예정 지점에 데미지 범위를 미리 표시.
func launch(from_position: Vector2, to_position: Vector2) -> void:
	origin = from_position
	target = to_position
	global_position = origin
	_show_landing_indicators()

## 착탄 지점(월드 좌표 고정)에 반경 aoe_radius의 데미지 범위 표시. 캐릭터가 이동해도 이 표시는
## 실제 폭발 위치에 그대로 고정되어야 하므로 owner_body가 아닌 부모(월드) 아래에 붙임.
## 착탄 시 한 지점이 아니라 여러 지점에 나눠 터지는 하위 클래스(알다발 등)는 오버라이드.
func _show_landing_indicators() -> void:
	_add_landing_indicator(target, aoe_radius)

func _add_landing_indicator(pos: Vector2, radius: float) -> void:
	var indicator := SkillRangeIndicator.new()
	indicator.radius = radius
	indicator.ring_color = Color(1.0, 0.25, 0.2, 0.55)
	indicator.fill_color = Color(1.0, 0.25, 0.2, 0.18)
	indicator.global_position = pos
	get_parent().add_child.call_deferred(indicator)
	_landing_indicators.append(indicator)

func _clear_landing_indicators() -> void:
	for indicator in _landing_indicators:
		if is_instance_valid(indicator):
			indicator.queue_free()
	_landing_indicators.clear()

func _physics_process(delta: float) -> void:
	if _landed:
		return
	_elapsed += delta
	var t := clampf(_elapsed / flight_time, 0.0, 1.0)
	global_position = origin.lerp(target, t)
	var height_t := sin(t * PI)  # 0→1→0. 크기 펄스/화면 상승/그림자가 전부 이 값 하나로 움직임
	_visual.scale = Vector2.ONE * lerpf(1.0, peak_scale, height_t)
	_visual.position.y = -height_t * arc_height_px
	_shadow.scale = Vector2.ONE * lerpf(1.0, 0.6, height_t)
	_shadow.modulate.a = lerpf(1.0, 0.4, height_t)
	_on_flight(t)
	if t >= 1.0:
		_land()

## 하위 클래스 오버라이드용. 매 물리 프레임, 위치/높이 갱신 직후 진행률 t(0~1)와 함께 호출.
## 기본 동작 없음 — 예: 알 폭탄이 이걸로 발사 시 랜덤 기울기를 궤적 각도로 서서히 정렬시킴.
func _on_flight(_t: float) -> void:
	pass

func _land() -> void:
	_landed = true
	_clear_landing_indicators()
	_on_landed()

## 하위 클래스 오버라이드용. 착탄 시 1회 호출. 기본 동작: 반경 aoe_radius 안의 적에게 폭발 데미지 후 소멸.
func _on_landed() -> void:
	_deal_aoe_damage(global_position, aoe_radius, damage)
	queue_free()
