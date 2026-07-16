class_name SkillRangeIndicator
extends Node2D
## 스킬 사거리를 원형(또는 부채꼴) 아웃라인으로 표시. SkillInstanceBase._show_range_indicator()가
## owner_body의 자식으로 붙여서, 캐릭터가 이동해도 자동으로 따라다닙니다.
## arc_degrees < 360 이면 facing_source.facing_direction 방향을 향하는 부채꼴로 그립니다.

@export var radius: float = 40.0
@export var ring_color: Color = Color(1.0, 1.0, 1.0, 0.35)
@export var fill_color: Color = Color(1.0, 1.0, 1.0, 0.1)
@export var line_width: float = 2.0
@export var arc_degrees: float = 360.0

var facing_source: Node  ## facing_direction 프로퍼티를 가진 노드. arc_degrees < 360일 때만 사용.

func _process(_delta: float) -> void:
	if arc_degrees < 360.0 and facing_source != null:
		var facing: Vector2 = facing_source.get("facing_direction")
		rotation = facing.angle()

func _draw() -> void:
	if arc_degrees >= 360.0:
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, ring_color, line_width, true)
		return
	var half := deg_to_rad(arc_degrees) / 2.0
	var segments := 24
	var points := PackedVector2Array()
	points.append(Vector2.ZERO)
	for i in range(segments + 1):
		var angle := -half + (2.0 * half * float(i) / float(segments))
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, fill_color)
	draw_polyline(points, ring_color, line_width, true)
