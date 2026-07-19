dino-survivor-develop (Godot 4 프로젝트)에 "진화 스킬 시스템"을 추가해줘. 다른 클라우드 세션에서 이미 설계/구현해본 내용인데, 로컬 저장소가 그 사이 다른 커밋(경험치/레벨 UI, 골드 드랍 정리 등)으로 갈라져서 patch(git am)가 그대로 안 먹혀. 그래서 patch를 복사하는 대신, 아래 스펙을 읽고 **지금 로컬 파일의 실제 현재 상태를 직접 열어본 다음** 그에 맞게 반영해줘. 특히 `autoload/run_state.gd`와 `scenes/ui/GameUI.tscn`은 최근 커밋들(경험치/레벨/골드 관련)이 이미 손댔을 가능성이 높으니, 기존 내용을 지우거나 덮어쓰지 말고 그 옆에 자연스럽게 추가해줘.

## 배경 / 설계 의도

- 스킬은 Lv1~5로 성장하고, Lv5(만렙)에 도달하면 "진화 선택 UI"가 떠서 진화 옵션 1~3개 중 하나를 플레이어가 고른다. 옵션이 1개뿐이어도 자동 적용이 아니라 확인 차원의 선택 UI가 뜬다.
- 진화형도 새 클래스가 아니라 기존 `SkillData`를 재사용한다. 다만 `data/skill_evolutions/`라는 별도 폴더에 보관하고 `max_level = 1`로 설정하며, `SkillDatabase`는 `data/skills/`만 스캔하므로 진화형은 레벨업 카드의 공용 풀에 절대 섞이지 않는다.
- 베이스 스킬(`SkillData`)이 `evolutions: Array[SkillData]` 필드로 자신의 진화 옵션들을 직접 가리킨다 (레시피 리소스 없이 1:N 직접 참조).
- 진화를 고르면 베이스 스킬은 슬롯에서 완전히 사라지고 고른 진화형으로 대체된다 (합체 때와 동일한 "슬롯 대체" 원칙).
- 예시로 '물기(bite)'의 진화형 2개를 추가한다: `bite_evo_1`(BiteEvo1, 더 크고 강력한 물기 — 기존 로직 재사용해 실제로 작동), `bite_evo_2`(BiteEvo2, 포효 컨셉 광역 디버프 — 디버프 시스템이 아직 없어서 로직 없는 더미).

## 1. 새로 만들 파일 (충돌 위험 없음 — 그대로 생성)

### `data/skill_evolutions/bite_evo_1.tres`
```
[gd_resource type="Resource" script_class="SkillData" format=3]

[ext_resource type="Script" path="res://resource_types/skill_data.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/skills/BiteSkill.tscn" id="2"]
[ext_resource type="PackedScene" path="res://scenes/skills/BiteHitEffect.tscn" id="3"]

[resource]
script = ExtResource("1")
id = &"bite_evo_1"
display_name = "BiteEvo1"
species_motif = "티라노사우루스"
flavor_text = "티라노사우루스의 턱 힘은 나이가 들수록 세진다고 합니다. 이쯤되면 물기가 아니라 그냥 압사 아닌가요? 한 입에 (데미지_숫자)의 피해를 입힙니다."
tags = Array[StringName](["suction"])
base_damage = 32.0
cooldown = 1.0
max_level = 1
effect_scene = ExtResource("3")
logic_scene = ExtResource("2")
icon_color = Color(1.0, 0.65, 0.05, 1)
```

### `data/skill_evolutions/bite_evo_2.tres`
```
[gd_resource type="Resource" script_class="SkillData" format=3]

[ext_resource type="Script" path="res://resource_types/skill_data.gd" id="1"]

[resource]
script = ExtResource("1")
id = &"bite_evo_2"
display_name = "BiteEvo2"
species_motif = "티라노사우루스"
flavor_text = "티라노사우루스의 포효는 반경 수십 미터의 초식동물을 얼어붙게 했다고 합니다. 요즘 회의실에서도 통할 것 같은데요? 포효와 함께 (데미지_숫자)의 피해를 주고, 주변 적을 둔화·약화시킵니다."
tags = Array[StringName](["burst", "debuff"])
base_damage = 20.0
cooldown = 4.0
max_level = 1
icon_color = Color(0.55, 0.15, 0.65, 1)
```

### `scenes/ui/EvolutionChoiceUI.tscn`
```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/ui/evolution_choice_ui.gd" id="1"]

[node name="EvolutionChoiceUI" type="Control"]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
visible = false
script = ExtResource("1")

[node name="DimBackground" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
color = Color(0, 0, 0, 0.55)

[node name="CardRow" type="HBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/separation = 24
```

### `scripts/ui/evolution_choice_ui.gd`
```gdscript
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
```

## 2. 기존 파일에 추가할 내용 (반드시 현재 파일을 먼저 읽고, 아래 "의도"에 맞게 자연스러운 위치에 삽입 — 줄 번호로 맹목적으로 끼워넣지 말 것)

### `resource_types/skill_data.gd`
`@export_group("씬 참조")`의 `logic_scene` 필드 바로 다음, `@export_group("패시브 효과")` 앞에 새 그룹을 추가:
```gdscript
@export_group("진화")
@export var evolutions: Array[SkillData] = []  ## 이 스킬이 만렙(Lv5)에 도달했을 때 제시할 진화 선택지 (1~3개, 기획서 4.3/4.5). 진화형 SkillData는 이 배열을 가진 "베이스 스킬"과 달리 data/skill_evolutions/ 에 따로 보관하고 max_level=1로 설정 — 공용 풀(SkillDatabase)에는 스캔되지 않음
```
(이미 `category`/`tags`/`passive_modifiers` 등이 추가돼 있을 텐데, 그 구조는 그대로 두고 `evolutions` 필드만 새로 끼워넣으면 됨. 만약 이 필드가 이미 존재한다면 건드리지 말 것.)

### `autoload/skill_database.gd`
클래스 최상단 주석에 아래 한 줄 추가 (data/skill_evolutions/를 의도적으로 스캔 안 한다는 설명):
```gdscript
## data/skill_evolutions/ 는 의도적으로 스캔하지 않습니다 — 진화형 스킬은
## 공용 풀에 노출되지 않고 오직 베이스 SkillData.evolutions를 통해서만 참조됩니다 (기획서 4.3).
```

### `autoload/run_state.gd` — **가장 주의해서 병합할 파일**
지금 파일에 경험치/레벨/골드 관련 신호와 변수가 이미 여러 개 있을 거야. 그 옆에 아래 3가지를 "추가"만 해줘 (기존 신호/변수 이름과 겹치지 않는지 확인하고, 겹치면 스킵):

1. 신호 2개 추가 (다른 `signal` 선언들 옆에):
```gdscript
signal skill_removed(id: StringName)                        ## 진화로 베이스 스킬이 슬롯에서 사라질 때 — HUD가 슬롯 제거
signal evolution_ready(base_data: SkillData)                ## 스킬이 만렙+진화 옵션 보유 상태가 됐을 때 — EvolutionChoiceUI가 선택 팝업을 띄움
```

2. 변수 1개 추가 (`is_game_over` 같은 다른 bool 플래그들 옆에):
```gdscript
var has_pending_evolution: bool = false  ## 진화 선택 UI가 떠 있는 동안 true — 레벨업 카드가 뒤이어 일시정지를 풀지 않도록 막는 가드
```

3. `reset_run()` 함수 안, 다른 초기화 줄들 옆에 한 줄 추가:
```gdscript
has_pending_evolution = false
```

4. 파일 하단에 새 함수 추가 (`is_skill_owned`/`skill_level` 같은 헬퍼 함수들 옆에):
```gdscript
## 진화 등으로 베이스 스킬이 슬롯에서 사라질 때 호출. skill_removed를 emit해 HUD 슬롯도 정리합니다.
func remove_skill(id: StringName) -> void:
	skill_levels.erase(id)
	for i in range(owned_skills.size()):
		if owned_skills[i].id == id:
			owned_skills.remove_at(i)
			break
	skill_removed.emit(id)
```
(`owned_skills: Array[SkillData]`, `skill_levels: Dictionary` 필드는 이미 있을 거야 — 이름이 다르면 실제 필드명에 맞춰서 조정)

### `scripts/systems/skill_controller.gd`
`acquire_skill(id)` 함수에서, 이미 보유한 스킬의 레벨을 올리는 분기(`if RunState.is_skill_owned(id): ...`) 안에 레벨업 emit 직후 아래 체크를 추가:
```gdscript
if RunState.skill_levels[id] >= data.max_level and not data.evolutions.is_empty():
	RunState.evolution_ready.emit(data)
```

그리고 파일 끝에 새 함수 추가:
```gdscript
## 진화 선택 UI에서 하나를 고르면 호출됩니다. 베이스 스킬을 슬롯에서 제거하고
## 그 자리를 진화형 스킬로 대체합니다 (기획서 4.3).
func evolve_skill(base_id: StringName, evolution_data: SkillData) -> void:
	if _instances.has(base_id):
		_instances[base_id].queue_free()
		_instances.erase(base_id)
	RunState.remove_skill(base_id)

	RunState.skill_levels[evolution_data.id] = evolution_data.max_level
	RunState.owned_skills.append(evolution_data)
	if evolution_data.logic_scene != null:
		var instance: SkillInstanceBase = evolution_data.logic_scene.instantiate()
		add_child(instance)
		instance.setup(evolution_data, owner_body)
		_instances[evolution_data.id] = instance
	RunState.skill_acquired.emit(evolution_data)
```
(`_instances: Dictionary`, `owner_body` 필드는 이미 있을 거야 — 실제 이름에 맞춰 조정)

### `scripts/ui/level_up_ui.gd`
`_on_card_selected` 함수에서 `get_tree().paused = false`를 무조건 실행하는 대신, 진화 선택이 이어서 뜬 경우엔 일시정지를 풀지 않도록 가드:
```gdscript
func _on_card_selected(data: SkillData) -> void:
	_get_skill_controller().acquire_skill(data.id)
	visible = false
	if not RunState.has_pending_evolution:
		get_tree().paused = false
```

### `scripts/ui/skill_hud.gd`
`_ready()`에서 다른 RunState 신호 연결하는 줄들 옆에 추가:
```gdscript
RunState.skill_removed.connect(_on_skill_removed)
```
그리고 새 함수 추가:
```gdscript
func _on_skill_removed(id: StringName) -> void:
	if _slots.has(id):
		_slots[id].queue_free()
		_slots.erase(id)
```
(`_slots: Dictionary` 필드는 이미 있을 거야)

### `data/skills/bite.tres`
파일 상단 `[ext_resource ...]` 목록 끝에 두 줄 추가 (기존 id 번호와 안 겹치는 새 id 사용, 예: 이미 1~3이 쓰였으면 4, 5):
```
[ext_resource type="Resource" path="res://data/skill_evolutions/bite_evo_1.tres" id="4"]
[ext_resource type="Resource" path="res://data/skill_evolutions/bite_evo_2.tres" id="5"]
```
`[resource]` 블록 안에 한 줄 추가 (여기서 `X`는 skill_data.gd 스크립트를 가리키는 ExtResource id — 보통 id="1"):
```
evolutions = Array[ExtResource("X")]([ExtResource("4"), ExtResource("5")])
```
(주의: `Array[ExtResource("X")]`의 X는 **skill_data.gd 스크립트의 ExtResource id**여야 함. bite_evo_1/bite_evo_2 리소스 자체의 id가 아님 — Godot이 타입 파라미터로 스크립트를 참조하는 방식)

### `scenes/ui/GameUI.tscn`
지금 이 파일에 경험치/레벨/골드 UI 노드들이 이미 추가돼 있을 거야. 그건 그대로 두고:
1. `[ext_resource ...]` 목록에 새 항목 추가 (id는 안 겹치는 번호로):
```
[ext_resource type="PackedScene" path="res://scenes/ui/EvolutionChoiceUI.tscn" id="N"]
```
2. `load_steps=` 값을 ext_resource 총 개수에 맞게 +1
3. `LevelUpUI` 노드 바로 다음 줄에 새 노드 인스턴스 추가:
```
[node name="EvolutionChoiceUI" parent="." instance=ExtResource("N")]
```

## 마무리
다 반영한 뒤, GDScript 문법이나 타입 에러가 없는지 한 번 더 읽어봐줘 (Godot 헤드리스 실행은 안 돼도 괜찮음). 그리고 실제로 로컬에서 Godot 에디터로 열어서 물기 스킬을 만렙까지 찍었을 때 진화 선택 UI가 뜨는지 플레이 테스트까지 해주면 좋겠어.
