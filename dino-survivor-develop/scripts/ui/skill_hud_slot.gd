class_name SkillHUDSlot
extends VBoxContainer
## 보유 스킬 HUD의 슬롯 하나. 아이콘(색상 사각형) + 그 아래 레벨 텍스트.

@onready var icon: ColorRect = $Icon
@onready var level_label: Label = $LevelLabel

func setup(data: SkillData, level: int) -> void:
	icon.color = data.icon_color
	set_level(level)

func set_level(level: int) -> void:
	level_label.text = "Lv.%d" % level
