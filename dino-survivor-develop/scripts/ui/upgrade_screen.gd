extends Control
## 골드로 영구 강화를 구매하는 화면. MetaProgress.try_purchase()를 호출하고 결과를 즉시 반영합니다.

const ATTACK_ID := &"attack_up"
const HEALTH_ID := &"health_up"

@onready var gold_label: Label = $Panel/VBox/GoldLabel
@onready var attack_button: Button = $Panel/VBox/AttackButton
@onready var health_button: Button = $Panel/VBox/HealthButton
@onready var back_button: Button = $Panel/VBox/BackButton

func _ready() -> void:
	attack_button.pressed.connect(func(): _try_purchase(ATTACK_ID))
	health_button.pressed.connect(func(): _try_purchase(HEALTH_ID))
	back_button.pressed.connect(_on_back_pressed)
	MetaProgress.gold_changed.connect(func(_new_total: int): _refresh())
	MetaProgress.upgrade_changed.connect(func(_id: StringName, _level: int): _refresh())
	_refresh()

func _try_purchase(id: StringName) -> void:
	MetaProgress.try_purchase(id)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")

func _refresh() -> void:
	gold_label.text = "보유 골드: %d" % MetaProgress.gold
	_refresh_button(attack_button, ATTACK_ID)
	_refresh_button(health_button, HEALTH_ID)

func _refresh_button(button: Button, id: StringName) -> void:
	var data := MetaProgress.get_upgrade(id)
	if data == null:
		button.text = "?"
		button.disabled = true
		return
	var level := MetaProgress.upgrade_level(id)
	if level >= data.max_level:
		button.text = "%s (MAX)" % data.display_name
		button.disabled = true
		return
	var cost := data.cost_for_level(level + 1)
	button.text = "%s Lv.%d → %d (%d 골드)" % [data.display_name, level, level + 1, cost]
	button.disabled = MetaProgress.gold < cost
