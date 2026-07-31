class_name LobbedShadow
extends Node2D
## 곡사형 투사체(BaseLobbedProjectile)가 공중에 떠 있는 동안 바닥에 남기는 그림자.
## 항상 로컬 (0,0)에 고정된 채로, 부모가 비행 진행률에 따라 scale/modulate.a만 조절합니다.
## 아직 그림자 아트가 없어서 _draw()로 즉석 렌더링합니다. squash(세로 눌림)는 폴리곤 자체에
## 반영해뒀으므로, 부모가 scale을 따로 애니메이션해도(높이에 따른 크기 변화) 타원 비율이 깨지지 않습니다.

@export var radius: float = 10.0
@export var color: Color = Color(0.0, 0.0, 0.0, 0.35)
@export var squash: float = 0.5  ## 세로 방향으로 눌러 타원처럼 보이게 하는 비율

func _draw() -> void:
	var points := PackedVector2Array()
	var segments := 24
	for i in range(segments):
		var angle := TAU * float(i) / float(segments)
		points.append(Vector2(cos(angle) * radius, sin(angle) * radius * squash))
	draw_colored_polygon(points, color)
