extends Node2D
## 물기 명중 시 잠깐 나타났다 사라지는 이펙트 (placeholder). 나중에 스프라이트/애니메이션으로 교체 예정.

@export var color: Color = Color(1.0, 0.9, 0.2, 0.9)
@export var start_radius: float = 14.0
@export var duration: float = 0.15

var _radius: float

func _ready() -> void:
	_radius = start_radius
	var tween := create_tween()
	tween.tween_method(_set_radius, start_radius, 0.0, duration)
	tween.tween_callback(queue_free)

func _set_radius(value: float) -> void:
	_radius = value
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, _radius, color)
