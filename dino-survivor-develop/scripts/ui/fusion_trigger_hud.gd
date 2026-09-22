extends Label
## 화면 좌측 상단, 골드 아래에 합체 트리거 아이템 보유 개수를 상시 표시.
## 0개면 완전히 숨겨서, 플레이어가 "지금 재료를 들고 있다"는 상태만 있을 때 눈에 띄게 함.
## RunState.fusion_trigger_count_changed 신호로 갱신 (gold_hud.gd와 동일한 반응형 바인딩 패턴).

func _ready() -> void:
	RunState.fusion_trigger_count_changed.connect(_on_count_changed)
	_on_count_changed(RunState.fusion_trigger_count)

func _on_count_changed(new_count: int) -> void:
	visible = new_count > 0
	text = "합체 재료 x%d" % new_count
