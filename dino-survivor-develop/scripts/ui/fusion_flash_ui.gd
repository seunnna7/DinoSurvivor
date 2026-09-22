extends ColorRect
## 합체가 발동하는 순간 화면 전체를 짧게 밝혔다 사라지는 플래시. 일시정지 없이,
## "지금 큰 일이 일어났다"는 걸 화면 구석의 텍스트보다 먼저 눈에 들어오게 하는 용도.

const FLASH_ALPHA := 0.55
const FADE_SECONDS := 0.4

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color.a = 0.0
	RunState.fusion_completed.connect(_on_fusion_completed)

func _on_fusion_completed(_result_data: SkillData) -> void:
	color.a = FLASH_ALPHA
	var tween := create_tween()
	tween.tween_property(self, "color:a", 0.0, FADE_SECONDS)
