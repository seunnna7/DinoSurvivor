extends Control
## 로비 화면. 캐릭터가 화면 안을 자유롭게 돌아다니다 상호작용 존(Zone)에 들어가면
## 해당 기능의 모달이 열리고, 존 밖으로 나가거나 모달의 닫기 버튼을 누르면 닫힙니다.
##
## 존 -> 모달 연결은 _zone_modals 딕셔너리(zone_id -> 모달 노드) 하나로만 관리합니다.
## 지금은 "진입 즉시 트리거" 방식이지만, 나중에 "F키 입력 시 상호작용" 등으로 바뀌어도
## 이 딕셔너리와 존 노드는 그대로 두고 _on_zone_entered/_on_zone_exited 연결부(또는 _process의
## 입력 체크)만 바꾸면 되도록 분리해 두었습니다.

@onready var gold_label: Label = $HudPanel/VBox/GoldLabel
@onready var character: CharacterBody2D = $LobbyCharacter
@onready var zones: Node2D = $Zones
@onready var fossil_ui: Control = $FossilRestorationUI
@onready var upgrade_ui: Control = $UpgradeUI
@onready var codex_ui: Control = $CodexUI
@onready var character_select_ui: Control = $CharacterSelectUI

var _zone_modals: Dictionary = {}  ## zone_id(StringName) -> 모달 Control
var _active_zone_id: StringName = &""

func _ready() -> void:
	_zone_modals = {
		&"enhance": upgrade_ui,
		&"fossil": fossil_ui,
		&"codex": codex_ui,
		&"start": character_select_ui,
	}
	for zone in zones.get_children():
		zone.player_entered.connect(_on_zone_entered)
		zone.player_exited.connect(_on_zone_exited)
	for modal in _zone_modals.values():
		modal.closed.connect(_on_modal_closed)
	MetaProgress.gold_changed.connect(_on_gold_changed)
	_on_gold_changed(MetaProgress.gold)

func _on_gold_changed(new_total: int) -> void:
	gold_label.text = "보유 골드: %d" % new_total

func _on_zone_entered(zone_id: StringName) -> void:
	if _active_zone_id != &"":
		return  ## 이미 다른 모달이 열려 있으면 무시 (존끼리 겹치지 않게 배치되어 있음)
	var modal: Control = _zone_modals.get(zone_id)
	if modal == null:
		return
	_active_zone_id = zone_id
	character.movement_enabled = false
	modal.open()

func _on_zone_exited(zone_id: StringName) -> void:
	if _active_zone_id != zone_id:
		return
	var modal: Control = _zone_modals.get(zone_id)
	if modal:
		modal.close()

func _on_modal_closed() -> void:
	_active_zone_id = &""
	character.movement_enabled = true
