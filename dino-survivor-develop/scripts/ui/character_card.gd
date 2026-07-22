class_name CharacterCard
extends PanelContainer
## 화석 복원 그리드의 캐릭터 카드 한 장. 초상화 + 이름 + 해금 상태를 표시하고,
## 미해금 상태면 해금하기 버튼을 눌러 unlock_requested 신호로 알립니다.

const LOCKED_MODULATE := Color(0.18, 0.18, 0.2, 1)  ## 미해금 실루엣 효과 (portrait.modulate에 곱해짐)
const UNLOCKED_MODULATE := Color(1, 1, 1, 1)

signal unlock_requested(id: StringName)

@onready var portrait: ColorRect = $Margin/VBox/Portrait
@onready var name_label: Label = $Margin/VBox/NameLabel
@onready var status_label: Label = $Margin/VBox/StatusLabel
@onready var unlock_button: Button = $Margin/VBox/UnlockButton

var _species: SpeciesData

func _ready() -> void:
	unlock_button.pressed.connect(_on_unlock_button_pressed)

func setup(species: SpeciesData, unlocked: bool) -> void:
	_species = species
	name_label.text = species.display_name
	portrait.modulate = UNLOCKED_MODULATE if unlocked else LOCKED_MODULATE
	status_label.text = "해금됨" if unlocked else "미해금"
	unlock_button.visible = not unlocked

func _on_unlock_button_pressed() -> void:
	unlock_requested.emit(_species.id)
