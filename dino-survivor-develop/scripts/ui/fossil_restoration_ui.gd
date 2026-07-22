extends Control
## 로비 위에 뜨는 화석 복원(캐릭터 해금) 모달. GameUI의 팝업들(pause_menu_ui.gd 등)과 같은 패턴으로
## visible을 토글하는 자체 포함형 오버레이입니다. SpeciesDatabase의 전 종족을 카드로 나열하고,
## 해금하기를 누르면 FossilProgress에 즉시 반영합니다 (추후 해금 조건 로직으로 교체 예정).

const CHARACTER_CARD_SCENE := preload("res://scenes/ui/CharacterCard.tscn")

signal closed  ## 로비가 구독해서 캐릭터 이동을 다시 켬

@onready var close_button: Button = $Panel/VBox/HeaderRow/CloseButton
@onready var grid: GridContainer = $Panel/VBox/GridScroll/GridContainer

func _ready() -> void:
	close_button.pressed.connect(close)
	visible = false

func open() -> void:
	visible = true
	_refresh()

func close() -> void:
	visible = false
	closed.emit()

func _refresh() -> void:
	for child in grid.get_children():
		child.queue_free()
	for species in SpeciesDatabase.all_species:
		var card: CharacterCard = CHARACTER_CARD_SCENE.instantiate()
		grid.add_child(card)
		card.setup(species, FossilProgress.is_unlocked(species.id))
		card.unlock_requested.connect(_on_unlock_requested)

func _on_unlock_requested(id: StringName) -> void:
	FossilProgress.unlock(id)
	_refresh()
