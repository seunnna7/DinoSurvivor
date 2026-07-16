extends Node2D
## 이동감을 눈으로 확인하기 위한 임시 배경 그리드입니다.
## 실제 아트(타일맵 등)가 들어가면 이 노드는 통째로 지워도 됩니다.

@export var cell_size: int = 100
@export var extent: int = 3000
@export var line_color: Color = Color(1, 1, 1, 0.12)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var x := -extent
	while x <= extent:
		draw_line(Vector2(x, -extent), Vector2(x, extent), line_color, 2.0)
		x += cell_size
	var y := -extent
	while y <= extent:
		draw_line(Vector2(-extent, y), Vector2(extent, y), line_color, 2.0)
		y += cell_size
