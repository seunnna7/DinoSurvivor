class_name EarthquakeCrack
extends BaseAreaEffect
## 지진의 균열 하나. BaseAreaEffect(장판형: 지속시간+페이드+hit_delay 전조)를 그대로 쓰되,
## 원형 대신 회전된 직사각형(rect_size, 이 노드의 rotation) 범위로 판정하도록
## _strike_all_overlapping()만 오버라이드합니다. 판정 자체는 물리 충돌이 아니라
## _deal_aoe_damage_box()의 수동 거리 계산이라, CollisionShape2D는 시각/일관성용입니다.
##
## hit_delay(BaseAreaEffect) 동안은 데미지 없이 흔들리기만 합니다 — Visual(Polygon2D)을
## 매 프레임 살짝 흔들다가(_process, _elapsed 기준) 판정 시점에 딱 멈춰서 "흔들리다 갈라지는"
## 전조를 표현합니다.

@export var rect_size: Vector2 = Vector2(260.0, 90.0)

@onready var _visual: Polygon2D = $Visual

var _shaking: bool = true

func _ready() -> void:
	_visual.polygon = _rect_polygon(rect_size)
	_sync_collision_rect(rect_size)
	super._ready()

func _process(_delta: float) -> void:
	if not _shaking:
		return
	if _elapsed >= hit_delay:
		_shaking = false
		_visual.position = Vector2.ZERO
		return
	_visual.position = Vector2(randf_range(-3.0, 3.0), randf_range(-3.0, 3.0))

func _strike_all_overlapping() -> void:
	_deal_aoe_damage_box(global_position, rotation, rect_size, damage, _on_tick_hit)

static func _rect_polygon(size: Vector2) -> PackedVector2Array:
	var half := size * 0.5
	return PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y),
	])
