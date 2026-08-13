extends Control
## 레벨업 시 스킬 카드 3장을 보여주고, 선택되면 SkillController.acquire_skill()을 호출합니다.
## 팝업이 떠 있는 동안 게임을 일시정지(get_tree().paused)하며, 이 노드 자신은
## process_mode = ALWAYS라 일시정지 중에도 카드 클릭을 받을 수 있습니다.

const CARD_COUNT := 3

## 이미 보유한 스킬이 선택지에 더 자주 뜨도록 하는 가중치 배수 (기획서 4.4의 "피티 시스템").
## 이게 없으면 스킬 하나를 만렙까지 찍기 어려워 진화·합체를 런 안에서 거의 볼 수 없습니다.
const OWNED_SKILL_WEIGHT := 3.0
const NEW_SKILL_WEIGHT := 1.0

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
	if picked.is_empty():
		return  ## 6슬롯이 전부 진화까지 끝나면 제시할 카드가 없음 — 팝업 없이 넘어감(일시정지 금지)
	for i in range(cards.size()):
		if i < picked.size():
			cards[i].visible = true
			cards[i].setup(picked[i], RunState.is_skill_owned(picked[i].id))
		else:
			cards[i].visible = false
	visible = true
	get_tree().paused = true

func _pick_random_skills(count: int) -> Array[SkillData]:
	var candidates := _candidate_skills()
	var picked: Array[SkillData] = []
	while picked.size() < count and not candidates.is_empty():
		var index := _pick_weighted_index(candidates)
		picked.append(candidates[index])
		candidates.remove_at(index)
	return picked

## 카드에 올릴 수 있는 스킬들. 만렙 스킬은 제외하고, 액티브 슬롯이 꽉 찼으면
## 미보유 액티브는 후보에서 빼서 보유 스킬 레벨업만 제시합니다.
## 진화를 마친 스킬의 원본은 보유 목록에서 빠지므로 여기서 다시 후보로 올라옵니다 (의도된 사양).
func _candidate_skills() -> Array[SkillData]:
	var has_free_slot := RunState.has_free_active_slot()
	var result: Array[SkillData] = []
	for data in SkillDatabase.get_common_pool_skills():
		if RunState.skill_level(data.id) >= data.max_level:
			continue
		if RunState.is_skill_owned(data.id):
			result.append(data)
		elif has_free_slot or data.category == SkillData.Category.PASSIVE:
			result.append(data)
	return result

func _pick_weighted_index(candidates: Array[SkillData]) -> int:
	var total := 0.0
	for data in candidates:
		total += _weight_of(data)
	var roll := randf() * total
	for i in range(candidates.size()):
		roll -= _weight_of(candidates[i])
		if roll <= 0.0:
			return i
	return candidates.size() - 1

func _weight_of(data: SkillData) -> float:
	return OWNED_SKILL_WEIGHT if RunState.is_skill_owned(data.id) else NEW_SKILL_WEIGHT

func _on_card_selected(data: SkillData) -> void:
	_get_skill_controller().acquire_skill(data.id)
	visible = false
	if not RunState.has_pending_evolution:
		get_tree().paused = false

func _get_skill_controller() -> SkillController:
	if _skill_controller == null:
		var player := get_tree().get_first_node_in_group("player")
		_skill_controller = player.get_node("SkillController") as SkillController
	return _skill_controller
