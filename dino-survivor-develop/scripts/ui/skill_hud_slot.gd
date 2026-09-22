class_name SkillHUDSlot
extends VBoxContainer
## 보유 스킬 HUD의 슬롯 하나. 아이콘(색상 사각형) + 그 아래 레벨 텍스트.

@onready var icon: ColorRect = $Icon
@onready var level_label: Label = $LevelLabel

var _max_level: int = 5

func setup(data: SkillData, level: int) -> void:
	icon.color = data.icon_color
	_max_level = data.max_level
	set_level(level)

func set_level(level: int) -> void:
	level_label.text = "Lv.Max" if level >= _max_level else "Lv.%d" % level

## 합체로 이 슬롯이 새로 생겼을 때 잠깐 눈에 띄게 반짝임 (스케일 펄스 + 밝기 상승).
func flash() -> void:
	pivot_offset = size / 2.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.35, 1.35), 0.18).set_ease(Tween.EASE_OUT)
	tween.tween_property(icon, "modulate", Color(1.6, 1.6, 1.6, 1), 0.18).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_property(self, "scale", Vector2.ONE, 0.35).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(icon, "modulate", Color(1, 1, 1, 1), 0.35).set_ease(Tween.EASE_IN)
