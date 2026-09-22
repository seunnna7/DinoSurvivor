extends Control
## 합체가 발동했을 때 화면 중앙 상단에 크게 튀어나오듯 뜨는 알림 패널.
## 일시정지나 카드 선택 없이 게임 진행을 막지 않는 순수 연출용이지만(VS-2 결정: 큰 수정 없이도
## "지금 합쳐졌다"는 게 확실히 보이도록), 작은 텍스트 한 줄이었던 이전 버전보다 훨씬 존재감 있게
## (배경 패널 + 팝업 애니메이션 + FusionFlashUI 화면 플래시와 동시 발생) 개선했습니다.

const POP_SECONDS := 0.35
const DISPLAY_SECONDS := 2.2
const FADE_SECONDS := 0.5

@onready var panel: PanelContainer = $Panel
@onready var result_label: Label = $Panel/VBox/ResultLabel

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.pivot_offset = panel.custom_minimum_size / 2.0  ## 스케일 애니메이션이 중심에서 튀어나오도록
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.75, 0.75)
	RunState.fusion_completed.connect(_on_fusion_completed)

func _on_fusion_completed(result_data: SkillData) -> void:
	result_label.text = "%s 완성!" % result_data.display_name

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, POP_SECONDS * 0.5)
	tween.tween_property(panel, "scale", Vector2.ONE, POP_SECONDS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_interval(DISPLAY_SECONDS)
	tween.tween_property(panel, "modulate:a", 0.0, FADE_SECONDS)
