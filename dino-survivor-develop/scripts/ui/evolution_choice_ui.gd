extends Control
## 스킬이 만렙+진화 옵션 보유 상태가 되면 뜨는 진화 선택 팝업.
## SkillCard를 재사용해 1~3장을 동적으로 배치합니다 (진화 옵션 개수만큼, 기획서 4.3/4.5).
## 레벨업 카드 선택 직후 곧바로 뜰 수 있어(RunState.has_pending_evolution),
## 팝업이 떠 있는 동안 게임을 일시정지합니다.

const CARD_SCENE := preload("res://scenes/ui/SkillCard.tscn")

@onready var card_row: HBoxContainer = $CardRow

var _base_data: SkillData
var _skill_controller: SkillController

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	RunState.evolution_ready.connect(_on_evolution_ready)

func _on_evolution_ready(base_data: SkillData) -> void:
	if RunState.is_game_over:
		return
	_base_data = base_data
	_open()

func _open() -> void:
	for child in card_row.get_children():
		child.queue_free()
	for evolution_data in _base_data.evolutions:
		var card: SkillCard = CARD_SCENE.instantiate()
		card_row.add_child(card)
		card.setup(evolution_data, false)
		card.selected.connect(_on_evolution_selected)
	RunState.has_pending_evolution = true
	visible = true
	get_tree().paused = true

func _on_evolution_selected(evolution_data: SkillData) -> void:
	_get_skill_controller().evolve_skill(_base_data.id, evolution_data)
	visible = false
	RunState.has_pending_evolution = false
	get_tree().paused = false

func _get_skill_controller() -> SkillController:
	if _skill_controller == null:
		var player := get_tree().get_first_node_in_group("player")
		_skill_controller = player.get_node("SkillController") as SkillController
	return _skill_controller
