extends CanvasLayer
## 개발자 전용 디버그 메뉴. 배포(release) 빌드에서는 자동으로 비활성화됩니다.
##
## 삭제 방법: 이 scripts/debug/ 폴더 전체와 project.godot의
## "DevTools=..." Autoload 한 줄만 지우면 됩니다. 유일하게 이 파일 밖에 있는 코드는
## scripts/systems/skill_controller.gd의 remove_skill() / dev_set_skill_level() 두 함수인데,
## 둘 다 "개발자 메뉴 전용" 주석이 붙어 있어 같이 지우면 완전히 원상복구됩니다.

const TIME_SCALES: Array[float] = [0.5, 1.0, 2.0, 3.0]

var _toggle_button: Button
var _panel: Panel
var _skill_list: VBoxContainer
var _invincible_button: Button
var _is_open: bool = false
var _dev_invincible: bool = false

func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	_build_ui()

func _process(_delta: float) -> void:
	var player := _get_player()
	_toggle_button.visible = player != null
	if player == null and _is_open:
		_close()
	if _dev_invincible and player != null:
		player.is_invincible = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_QUOTELEFT:
		_toggle_menu()
		get_viewport().set_input_as_handled()

func _toggle_menu() -> void:
	if _get_player() == null:
		return
	if _is_open:
		_close()
	else:
		_open()

func _open() -> void:
	_refresh_skill_list()
	_panel.visible = true
	_is_open = true
	get_tree().paused = true

func _close() -> void:
	_panel.visible = false
	_is_open = false
	if not RunState.has_pending_evolution and not RunState.is_game_over:
		get_tree().paused = false

func _get_player() -> Player:
	return get_tree().get_first_node_in_group("player") as Player

func _get_skill_controller() -> SkillController:
	var player := _get_player()
	if player == null:
		return null
	return player.get_node("SkillController") as SkillController

# --- UI 빌드 (전부 코드로 생성 — 별도 씬/Prefab 없음) ---

func _build_ui() -> void:
	_toggle_button = _make_button("[DEV] 메뉴 (~)", _toggle_menu)
	_toggle_button.modulate = Color(1, 0.4, 0.4, 1)
	add_child(_toggle_button)
	_toggle_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 16)

	_panel = Panel.new()
	_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.visible = false
	_panel.custom_minimum_size = Vector2(420, 560)
	add_child(_panel)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)

	var margin := MarginContainer.new()
	margin.process_mode = Node.PROCESS_MODE_ALWAYS
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 12)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.process_mode = Node.PROCESS_MODE_ALWAYS
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "[DEV] 개발자 메뉴  (~ 키로 열고 닫기)"
	vbox.add_child(title)

	vbox.add_child(_build_row([
		_make_button("레벨업 +1", _on_level_up_pressed),
		_make_button("풀피 회복", _on_full_heal_pressed),
		_make_button("즉사", _on_kill_pressed),
	]))

	_invincible_button = _make_button("무적: OFF", _on_toggle_invincible_pressed)
	vbox.add_child(_build_row([_invincible_button]))

	var time_label := Label.new()
	time_label.text = "타임스케일"
	vbox.add_child(time_label)
	var time_row := HBoxContainer.new()
	time_row.process_mode = Node.PROCESS_MODE_ALWAYS
	for scale in TIME_SCALES:
		time_row.add_child(_make_button("%sx" % scale, _on_time_scale_pressed.bind(scale)))
	vbox.add_child(time_row)

	var skill_label := Label.new()
	skill_label.text = "스킬 (레벨 지정 / 획득 / 삭제)"
	vbox.add_child(skill_label)

	var scroll := ScrollContainer.new()
	scroll.process_mode = Node.PROCESS_MODE_ALWAYS
	scroll.custom_minimum_size = Vector2(0, 300)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	_skill_list = VBoxContainer.new()
	_skill_list.process_mode = Node.PROCESS_MODE_ALWAYS
	_skill_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_skill_list)

	vbox.add_child(_build_row([_make_button("닫기", _close)]))

func _build_row(buttons: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.process_mode = Node.PROCESS_MODE_ALWAYS
	for b in buttons:
		row.add_child(b)
	return row

func _make_button(text: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.process_mode = Node.PROCESS_MODE_ALWAYS
	b.pressed.connect(callback)
	return b

func _refresh_skill_list() -> void:
	for child in _skill_list.get_children():
		child.queue_free()
	for data in SkillDatabase.all_skills:
		_skill_list.add_child(_build_skill_row(data))
	_invincible_button.text = "무적: ON" if _dev_invincible else "무적: OFF"

func _build_skill_row(data: SkillData) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.process_mode = Node.PROCESS_MODE_ALWAYS
	var level := RunState.skill_level(data.id)
	var label := Label.new()
	label.text = "%s (Lv.%d/%d)" % [data.display_name, level, data.max_level]
	label.custom_minimum_size = Vector2(220, 0)
	row.add_child(label)
	row.add_child(_make_button("-", _on_skill_level_down.bind(data.id)))
	row.add_child(_make_button("+", _on_skill_level_up.bind(data.id)))
	row.add_child(_make_button("삭제", _on_skill_remove.bind(data.id)))
	return row

# --- 액션 ---

func _on_level_up_pressed() -> void:
	RunState.add_experience(RunState.xp_to_next_level())

func _on_full_heal_pressed() -> void:
	var player := _get_player()
	if player == null:
		return
	player.health = player.max_health
	player.health_changed.emit(player.health, player.max_health)

func _on_kill_pressed() -> void:
	var player := _get_player()
	if player == null:
		return
	player.health = 0.0
	player.health_changed.emit(0.0, player.max_health)
	player.died.emit()

func _on_toggle_invincible_pressed() -> void:
	_dev_invincible = not _dev_invincible
	_invincible_button.text = "무적: ON" if _dev_invincible else "무적: OFF"
	if not _dev_invincible:
		var player := _get_player()
		if player != null:
			player.is_invincible = false

func _on_time_scale_pressed(scale: float) -> void:
	Engine.time_scale = scale

func _on_skill_level_up(id: StringName) -> void:
	var controller := _get_skill_controller()
	if controller == null:
		return
	controller.acquire_skill(id)
	_refresh_skill_list()

func _on_skill_level_down(id: StringName) -> void:
	var controller := _get_skill_controller()
	if controller == null:
		return
	controller.dev_set_skill_level(id, RunState.skill_level(id) - 1)
	_refresh_skill_list()

func _on_skill_remove(id: StringName) -> void:
	var controller := _get_skill_controller()
	if controller == null:
		return
	controller.remove_skill(id)
	_refresh_skill_list()
