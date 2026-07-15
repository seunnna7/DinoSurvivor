class_name MaceImpactEffect
extends Node2D
## 철퇴가 부채꼴 범위를 휘두르는 막대 이펙트 (placeholder). 나중에 스프라이트/애니메이션으로 교체 예정.
## owner_body의 자식으로 붙어서 재생되는 동안에도 플레이어 위치를 실시간으로 따라갑니다.

@export var color: Color = Color(1.0, 0.55, 0.1, 0.9)
@export var length: float = 90.0
@export var thickness: float = 10.0
@export var duration: float = 0.2
@export var arc_degrees: float = 90.0
@export var facing_angle: float = 0.0  ## 스폰 전에 설정. 부채꼴이 향하는 중심 각도.

func _ready() -> void:
	var half := deg_to_rad(arc_degrees) / 2.0
	rotation = facing_angle - half
	var tween := create_tween()
	tween.tween_property(self, "rotation", facing_angle + half, duration)
	tween.parallel().tween_property(self, "modulate:a", 0.0, duration * 0.4).set_delay(duration * 0.6)
	tween.tween_callback(queue_free)

func _draw() -> void:
	draw_rect(Rect2(0.0, -thickness / 2.0, length, thickness), color)
