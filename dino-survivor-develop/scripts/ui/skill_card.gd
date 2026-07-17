class_name SkillCard
extends Button
## 레벨업 팝업의 스킬 카드 한 장. 아이콘(색상 사각형) + 이름 + 설명 + 보유 여부를 표시하고,
## 클릭되면 selected 신호로 선택된 스킬 데이터를 알립니다.

signal selected(data: SkillData)

@onready var icon_rect: ColorRect = $Margin/VBox/Icon
@onready var name_label: Label = $Margin/VBox/NameLabel
@onready var tags_label: Label = $Margin/VBox/TagsLabel
@onready var description_label: Label = $Margin/VBox/DescriptionLabel
@onready var owned_label: Label = $Margin/VBox/OwnedLabel

var _data: SkillData

func _ready() -> void:
	pressed.connect(_on_pressed)

func setup(data: SkillData, owned: bool) -> void:
	_data = data
	icon_rect.color = data.icon_color
	name_label.text = data.display_name
	tags_label.text = TagDatabase.joined_display_names(data.tags)
	tags_label.visible = not data.tags.is_empty()
	description_label.text = data.description()
	owned_label.visible = owned
	if owned:
		owned_label.text = "보유 중 (Lv.%d)" % RunState.skill_level(data.id)

func _on_pressed() -> void:
	selected.emit(_data)
