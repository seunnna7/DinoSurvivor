extends HBoxContainer
## 화면 하단 중앙에 보유 스킬 아이콘 + 레벨을 가로로 표시하는 HUD.
## RunState.skill_acquired/skill_leveled_up 신호로 실시간 갱신됩니다.

const SLOT_SCENE := preload("res://scenes/ui/SkillHUDSlot.tscn")

var _slots: Dictionary = {}  # StringName(스킬 id) -> SkillHUDSlot

func _ready() -> void:
	RunState.skill_acquired.connect(_on_skill_acquired)
	RunState.skill_leveled_up.connect(_on_skill_leveled_up)
	RunState.skill_removed.connect(_on_skill_removed)
	for data in RunState.owned_skills:
		_add_slot(data)

func _add_slot(data: SkillData) -> void:
	if data.category == SkillData.Category.PASSIVE:
		return  ## 패시브는 보유 스킬 HUD에 노출하지 않음 (기획서 3.1)
	if _slots.has(data.id):
		return
	var slot: SkillHUDSlot = SLOT_SCENE.instantiate()
	add_child(slot)
	slot.setup(data, RunState.skill_level(data.id))
	_slots[data.id] = slot

func _on_skill_acquired(data: SkillData) -> void:
	_add_slot(data)

func _on_skill_leveled_up(data: SkillData, new_level: int) -> void:
	if _slots.has(data.id):
		_slots[data.id].set_level(new_level)

func _on_skill_removed(id: StringName) -> void:
	if _slots.has(id):
		_slots[id].queue_free()
		_slots.erase(id)
