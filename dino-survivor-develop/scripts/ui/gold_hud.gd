extends Label
## 화면 좌측 상단, 이번 런에서 획득한 골드를 실시간으로 표시.
## RunState.gold_changed 신호로 갱신됩니다 (health_bar.gd와 동일한 반응형 바인딩 패턴).

func _ready() -> void:
	RunState.gold_changed.connect(_on_gold_changed)
	_on_gold_changed(RunState.gold)

func _on_gold_changed(new_total: int) -> void:
	text = "Gold: %d" % new_total
