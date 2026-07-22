extends CharacterBody2D
## 로비에서 자유롭게 돌아다니는 캐릭터. player.gd의 이동 입력 규칙만 가져온 경량 버전으로,
## 체력/스킬 등 전투 관련 로직은 없습니다. 화석 복원 모달이 열리면 movement_enabled를 꺼서 멈춥니다.

const LOBBY_WIDTH := 1920.0
const LOBBY_HEIGHT := 1080.0
const EDGE_MARGIN := 32.0  ## 화면 경계에 딱 붙지 않도록 여유를 둠

@export var move_speed: float = 220.0

var movement_enabled: bool = true

@onready var visual: AnimatedSprite2D = $Visual

func _ready() -> void:
	add_to_group(&"lobby_player")

func _physics_process(_delta: float) -> void:
	if not movement_enabled:
		velocity = Vector2.ZERO
		_update_visual(Vector2.ZERO)
		return
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * move_speed
	move_and_slide()
	position.x = clampf(position.x, EDGE_MARGIN, LOBBY_WIDTH - EDGE_MARGIN)
	position.y = clampf(position.y, EDGE_MARGIN, LOBBY_HEIGHT - EDGE_MARGIN)
	_update_visual(input_dir)

## 스프라이트 시트가 왼쪽 기준이라 player.gd와 동일한 규칙으로 오른쪽 이동일 때만 flip_h.
func _update_visual(input_dir: Vector2) -> void:
	if input_dir.x != 0.0:
		visual.flip_h = input_dir.x > 0.0
	var next_animation: StringName = &"walking" if input_dir != Vector2.ZERO else &"standing"
	if visual.animation != next_animation:
		visual.play(next_animation)
