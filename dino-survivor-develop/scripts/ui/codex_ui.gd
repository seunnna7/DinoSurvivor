extends Control
## 로비 위에 뜨는 도감 모달. 아직 도감 콘텐츠가 없어 준비 중 안내만 표시하는 자리 표시자입니다.
## FossilRestorationUI/UpgradeUI와 같은 open()/close()/closed 패턴을 따릅니다.

signal closed  ## 로비가 구독해서 캐릭터 이동을 다시 켬

@onready var close_button: Button = $Panel/VBox/HeaderRow/CloseButton

func _ready() -> void:
	close_button.pressed.connect(close)
	visible = false

func open() -> void:
	visible = true

func close() -> void:
	visible = false
	closed.emit()
