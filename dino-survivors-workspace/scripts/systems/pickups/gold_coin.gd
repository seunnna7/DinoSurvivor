extends Area2D
## 골드 코인. 플레이어가 닿으면 RunState.gold에 누적됩니다.
## 골드 기반 통합 강화 시스템(기획서 5.1 참고 맥락)은 별도 마일스톤에서 연결 예정.

@export var gold_value: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	RunState.gold += gold_value
	queue_free()
