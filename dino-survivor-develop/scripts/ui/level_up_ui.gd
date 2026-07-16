extends Control
## 레벨업 시 스킬 카드 3장을 보여주고, 선택되면 SkillController.acquire_skill()을 호출합니다.
## 팝업이 떠 있는 동안 게임을 일시정지(get_tree().paused)하며, 이 노드 자신은
## process_mode = ALWAYS라 일시정지 중에도 카드 클릭을 받을 수 있습니다.

const CARD_COUNT := 3

@onready var cards: Array[SkillCard] = [
	$CardRow/Card1 as SkillCard,
	$CardRow/Card2 as SkillCard,
	$CardRow/Card3 as SkillCard,
]

var _skill_controller: SkillController

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	RunState.leveled_up.connect(_on_leveled_up)
	for card in cards:
		card.selected.connect(_on_card_selected)

func _on_leveled_up(_new_level: int) -> void:
	if RunState.is_game_over:
		return
	_open()

func _open() -> void:
	var picked := _pick_random_skills(CARD_COUNT)
	for i in range(cards.size()):
		if i < picked.size():
			cards[i].visible = true
			cards[i].setup(picked[i], RunState.is_skill_owned(picked[i].id))
		else:
			cards[i].visible = false
	visible = true
	get_tree().paused = true

func _pick_random_skills(count: int) -> Array[SkillData]:
	var pool := SkillDatabase.get_common_pool_skills()
	pool.shuffle()
	var picked: Array[SkillData] = []
	for i in range(min(count, pool.size())):
		picked.append(pool[i])
	return picked

func _on_card_selected(data: SkillData) -> void:
	_get_skill_controller().acquire_skill(data.id)
	visible = false
	get_tree().paused = false

func _get_skill_controller() -> SkillController:
	if _skill_controller == null:
		var player := get_tree().get_first_node_in_group("player")
		_skill_controller = player.get_node("SkillController") as SkillController
	return _skill_controller
