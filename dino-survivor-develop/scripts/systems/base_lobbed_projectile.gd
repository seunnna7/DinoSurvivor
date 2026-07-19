class_name BaseLobbedProjectile
extends BaseAttackObject
## 곡사형(포물선) 공격 오브젝트의 공통 로직. 출발지에서 목표 지점까지 flight_time 동안
## 이동하며, 비행 중에는 아무것도 타격하지 않다가(monitoring을 꺼서 충돌 자체를 무시) 도착하면
## _on_landed()를 호출합니다. 기본 구현은 반경 aoe_radius 안의 적에게 즉시 폭발 데미지.
##
## "포물선"의 시각적 표현: 탑다운 2D라 실제 Z축 낙하는 없으므로, 이동 자체는 출발점→목표점
## 직선 보간(lerp)으로 처리하고, 비행 중 scale을 사인 곡선으로 부풀렸다 줄여서
## "떠올랐다 떨어지는" 느낌만 흉내냅니다. 이 스케일 트릭은 순수 시각 연출이라 충돌 판정과 무관합니다.

@export var flight_time: float = 0.6
@export var aoe_radius: float = 50.0
@export var peak_scale: float = 1.6  ## 비행 정점(t=0.5)에서 커지는 배율

var origin: Vector2 = Vector2.ZERO
var target: Vector2 = Vector2.ZERO

var _elapsed: float = 0.0
var _landed: bool = false

func _ready() -> void:
	super._ready()
	monitoring = false  # 비행 중에는 아무것도 타격하지 않음 — 착탄 시에만 _on_landed()로 폭발 판정

## 스폰 직후 호출. 출발지/목표 착탄 지점을 설정.
func launch(from_position: Vector2, to_position: Vector2) -> void:
	origin = from_position
	target = to_position
	global_position = origin

func _physics_process(delta: float) -> void:
	if _landed:
		return
	_elapsed += delta
	var t := clampf(_elapsed / flight_time, 0.0, 1.0)
	global_position = origin.lerp(target, t)
	scale = Vector2.ONE * lerpf(1.0, peak_scale, sin(t * PI))  # 0→1→0으로 부풀었다 줄어듦
	if t >= 1.0:
		_land()

func _land() -> void:
	_landed = true
	_on_landed()

## 하위 클래스 오버라이드용. 착탄 시 1회 호출. 기본 동작: 반경 aoe_radius 안의 적에게 폭발 데미지 후 소멸.
func _on_landed() -> void:
	_deal_aoe_damage(global_position, aoe_radius, damage)
	queue_free()
