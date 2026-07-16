extends Control
## 캐릭터 선택 화면. 왼쪽 목록에서 캐릭터를 고르면 오른쪽 스탯 패널이 갱신되고,
## 아래 게임 시작 버튼을 누르면 선택된 캐릭터로 RunState.current_species를 채운 뒤 런을 시작합니다.

@onready var list_box: VBoxContainer = $Panel/VBox/ContentRow/ListPanel/ListScroll/ListBox
@onready var portrait: ColorRect = $Panel/VBox/ContentRow/StatPanel/Portrait
@onready var name_label: Label = $Panel/VBox/ContentRow/StatPanel/NameLabel
@onready var flavor_label: Label = $Panel/VBox/ContentRow/StatPanel/FlavorLabel
@onready var stats_label: Label = $Panel/VBox/ContentRow/StatPanel/StatsLabel
@onready var start_button: Button = $Panel/VBox/StartButton
@onready var back_button: Button = $Panel/VBox/HeaderRow/BackButton

var _selected: SpeciesData
var _buttons: Dictionary = {}  ## SpeciesData -> Button

func _ready() -> void:
	for species in SpeciesDatabase.all_species:
		var button := Button.new()
		button.text = species.display_name
		button.toggle_mode = true
		button.pressed.connect(_on_species_button_pressed.bind(species))
		list_box.add_child(button)
		_buttons[species] = button
	start_button.pressed.connect(_on_start_pressed)
	back_button.pressed.connect(_on_back_pressed)
	if not SpeciesDatabase.all_species.is_empty():
		_select(SpeciesDatabase.all_species[0])

func _on_species_button_pressed(species: SpeciesData) -> void:
	_select(species)

func _select(species: SpeciesData) -> void:
	_selected = species
	for s in _buttons:
		_buttons[s].button_pressed = (s == species)
	name_label.text = species.display_name
	flavor_label.text = species.passive_flavor_text
	var mods := species.passive_modifiers
	var max_health := StatCalculator.compute(StatTypes.DEFAULT_VALUE[&"max_health"], &"max_health", mods)
	var damage_mult := StatCalculator.compute(StatTypes.DEFAULT_VALUE[&"damage_mult"], &"damage_mult", mods)
	var move_speed := StatCalculator.compute(StatTypes.DEFAULT_VALUE[&"move_speed"], &"move_speed", mods)
	var armor := StatCalculator.compute(StatTypes.DEFAULT_VALUE[&"armor"], &"armor", mods)
	stats_label.text = "최대 체력: %d\n공격력: %d%%\n이동속도: %d\n방어력: %d" % [
		int(max_health), int(damage_mult * 100.0), int(move_speed), int(armor)
	]

func _on_start_pressed() -> void:
	if _selected == null:
		return
	RunState.current_species = _selected
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
