extends CanvasLayer
## 개발자 전용 디버그 오버레이. 배포(release) 빌드에서는 자동으로 비활성화됩니다.
## 다른 어떤 파일도 이 노드를 참조하지 않으므로, 이 파일과 project.godot의
## Autoload 등록 한 줄만 지우면 프로젝트 구조에 아무 영향 없이 완전히 제거됩니다.

var _level_up_button: Button

func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100

	_level_up_button = Button.new()
	_level_up_button.text = "[DEV] 레벨업"
	_level_up_button.modulate = Color(1, 0.4, 0.4, 1)
	_level_up_button.process_mode = Node.PROCESS_MODE_ALWAYS
	_level_up_button.pressed.connect(_on_level_up_pressed)
	add_child(_level_up_button)
	_level_up_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 16)

## 런(게임 플레이) 화면에서만 보이도록 매 프레임 player 그룹 존재 여부로 토글
func _process(_delta: float) -> void:
	_level_up_button.visible = get_tree().get_first_node_in_group("player") != null

## RunState.add_experience()만 호출 — is_game_over 가드 등 기존 레벨업 로직을 그대로 탑니다.
func _on_level_up_pressed() -> void:
	RunState.add_experience(RunState.xp_to_next_level())
