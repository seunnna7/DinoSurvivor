extends Area2D
## 경험치 젬. 플레이어가 닿으면 RunState.experience에 누적됩니다.
## 실제 레벨업 판정/UI는 G4(레벨업 UI)에서 연결 예정.

@export var xp_value: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	RunState.experience += xp_value
	queue_free()
