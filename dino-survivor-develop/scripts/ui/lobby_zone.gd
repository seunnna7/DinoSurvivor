class_name LobbyZone
extends Area2D
## 로비의 상호작용 영역(반투명 사각형 + 라벨). 캐릭터가 들어오고 나가는 것만 감지해서
## player_entered/player_exited 신호로 알립니다. 존 자체는 "어떤 모달을 여는지" 모르며,
## 그 연결은 lobby.gd가 zone_id 기준으로 관리합니다.
##
## 지금은 "진입 즉시 트리거" 방식이지만, 나중에 "F키 입력 시 상호작용"으로 바뀌어도
## 이 스크립트는 그대로 두고 lobby.gd에서 player_entered/exited 대신
## is_player_inside + 입력 체크로 트리거 조건만 바꾸면 됩니다.

signal player_entered(zone_id: StringName)
signal player_exited(zone_id: StringName)

@export var zone_id: StringName = &""
@export var display_name: String = "":
	set(value):
		display_name = value
		if is_node_ready():
			label.text = value
@export var zone_size: Vector2 = Vector2(260, 180):
	set(value):
		zone_size = value
		if is_node_ready():
			_apply_size()

var is_player_inside: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	label.text = display_name
	_apply_size()

func _apply_size() -> void:
	var shape := RectangleShape2D.new()
	shape.size = zone_size
	collision_shape.shape = shape
	label.position = -zone_size / 2.0
	label.size = zone_size
	queue_redraw()

func _draw() -> void:
	var half := zone_size / 2.0
	draw_rect(Rect2(-half, zone_size), Color(0.3, 0.55, 0.8, 0.35))
	draw_rect(Rect2(-half, zone_size), Color(0.5, 0.75, 1.0, 0.9), false, 2.0)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"lobby_player"):
		return
	is_player_inside = true
	player_entered.emit(zone_id)

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group(&"lobby_player"):
		return
	is_player_inside = false
	player_exited.emit(zone_id)
