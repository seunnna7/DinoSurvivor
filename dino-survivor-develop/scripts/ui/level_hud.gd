extends Control
## 화면 상단 중앙, 현재 레벨 텍스트와 경험치 게이지 바를 표시.
## RunState.leveled_up / experience_changed 신호로 실시간 갱신됩니다 (health_bar.gd와 동일한 반응형 바인딩 패턴).
## 경험치 바는 수치 텍스트 없이 채워지는 정도로만 진행 상황을 보여줍니다.

@onready var _level_label: Label = $LevelLabel
@onready var _xp_bar: ProgressBar = $ExperienceBar

func _ready() -> void:
	RunState.leveled_up.connect(_on_leveled_up)
	RunState.experience_changed.connect(_on_experience_changed)
	_on_leveled_up(RunState.level)
	_on_experience_changed(RunState.experience, RunState.xp_to_next_level())

func _on_leveled_up(new_level: int) -> void:
	_level_label.text = "LV. %d" % new_level

func _on_experience_changed(current: int, needed: int) -> void:
	_xp_bar.max_value = needed
	_xp_bar.value = current
