extends Area2D
## 경험치 젬. 플레이어가 닿으면 RunState.add_experience()로 누적되고, 임계값을 넘으면
## RunState가 leveled_up을 emit해 레벨업 카드 UI가 자동으로 뜹니다.
##
## 소(XPGemSmall)/중(XPGemMedium)/대(XPGemLarge) 3종 씬이 이 스크립트 하나를 공유하며,
## xp_value만 씬별로 다르게 오버라이드합니다 (기본 5/10/20, 추후 밸런싱 시 조정 예정).
## 드랍 확률/조합은 몹마다 다르므로 코드가 아니라 각 몹의 LootTable(.tres)에서 정합니다.

@export var xp_value: int = 5

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	RunState.add_experience(xp_value)
	queue_free()
