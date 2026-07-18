extends Control
## 플레이어 사망(Player.died) 시 게임을 정지하고 GAME OVER 팝업을 띄웁니다.
## process_mode = ALWAYS라 일시정지 중에도 버튼 클릭을 받을 수 있습니다.
## mouse_filter = STOP(기본값)으로 뒤쪽 UI(레벨업 카드 등)로 클릭이 새지 않게 막습니다.

@onready var retry_button: Button = $Panel/VBox/RetryButton
@onready var main_menu_button: Button = $Panel/VBox/MainMenuButton
@onready var survival_time_label: Label = $Panel/VBox/SurvivalTimeLabel

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
	MetaProgress.add_gold(RunState.gold)  # 런 종료 시점에 이번 판 골드를 보유 골드에 1회 합산
	survival_time_label.text = "최종 생존시간: %s" % RunState.format_time(RunState.elapsed_time)
	visible = true
	get_tree().paused = true

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
