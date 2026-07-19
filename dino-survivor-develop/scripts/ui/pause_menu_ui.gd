extends Control
## ESC 키(ui_cancel)로 게임을 일시정지/재개합니다.
## process_mode = ALWAYS라 일시정지 중에도 이 노드 자신은 입력(ESC, 버튼 클릭)을 받을 수 있습니다.
## 레벨업/진화 카드 등 다른 팝업이 이미 게임을 일시정지시켜 놓은 동안에는 ESC를 무시해서
## 그 팝업을 강제로 닫아버리지 않게 합니다.

@onready var resume_button: Button = $Panel/VBox/ResumeButton
@onready var quit_button: Button = $Panel/VBox/QuitButton

var _is_open: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if RunState.is_game_over:
		return
	if _is_open:
		_close()
	elif not get_tree().paused:
		_open()
	get_viewport().set_input_as_handled()

func _open() -> void:
	visible = true
	_is_open = true
	get_tree().paused = true

func _close() -> void:
	visible = false
	_is_open = false
	get_tree().paused = false

func _on_resume_pressed() -> void:
	_close()

## '그만하기': 일시정지 메뉴를 닫고 플레이어의 died 신호를 직접 울려 GameOverUI의
## 기존 사망 처리 로직(is_game_over, 골드 합산, 결과창 표시)을 그대로 재사용합니다.
func _on_quit_pressed() -> void:
	_close()
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null:
		player.died.emit()
