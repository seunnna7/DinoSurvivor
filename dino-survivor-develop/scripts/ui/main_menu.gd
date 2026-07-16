extends Control
## 게임 부팅 시 첫 화면. 보유 골드를 보여주고, 게임 시작/강화 화면으로 이동합니다.

@onready var gold_label: Label = $Panel/VBox/GoldLabel
@onready var start_button: Button = $Panel/VBox/StartButton
@onready var upgrade_button: Button = $Panel/VBox/UpgradeButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	MetaProgress.gold_changed.connect(_on_gold_changed)
	_on_gold_changed(MetaProgress.gold)

func _on_gold_changed(new_total: int) -> void:
	gold_label.text = "보유 골드: %d" % new_total

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/CharacterSelect.tscn")

func _on_upgrade_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/UpgradeScreen.tscn")
