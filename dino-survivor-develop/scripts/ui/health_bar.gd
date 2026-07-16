extends ProgressBar
## 보유 스킬 UI 아래, 화면 하단 중앙에 상시 노출되는 플레이어 체력바.
## Player.health_changed 신호로 실시간 갱신됩니다.

func _ready() -> void:
	min_value = 0.0
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	player.health_changed.connect(_on_health_changed)
	_on_health_changed(player.health, player.max_health)

func _on_health_changed(current: float, max_hp: float) -> void:
	max_value = max_hp
	value = current
