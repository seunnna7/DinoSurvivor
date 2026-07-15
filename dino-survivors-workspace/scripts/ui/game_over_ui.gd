extends Control
## 플레이어 사망(Player.died) 시 게임을 정지하고 GAME OVER 팝업을 띄웁니다.
## process_mode = ALWAYS라 일시정지 중에도 버튼 클릭을 받을 수 있습니다.
## mouse_filter = STOP(기본값)으로 뒤쪽 UI(레벨업 카드 등)로 클릭이 새지 않게 막습니다.

@onready var retry_button: Button = $Panel/VBox/RetryButton
@onready var main_menu_button: Button = $Panel/VBox/MainMenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null:
		player.died.connect(_on_player_died)

func _on_player_died() -> void:
	if visible:
		return
	RunState.is_game_over = true
	visible = true
	get_tree().paused = true

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	# 메인 메뉴/타이틀 씬이 아직 없어 실제 이동 대신 로그만 남깁니다.
	print("메인 메뉴로 이동 (아직 해당 씬이 없어 임시 로그 처리)")
