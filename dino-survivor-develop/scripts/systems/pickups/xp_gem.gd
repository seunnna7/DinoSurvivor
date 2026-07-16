extends Area2D
## 경험치 젬. 플레이어가 닿으면 RunState.add_experience()로 누적되고, 임계값을 넘으면
## RunState가 leveled_up을 emit해 레벨업 카드 UI가 자동으로 뜹니다.

@export var xp_value: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	RunState.add_experience(xp_value)
	queue_free()
