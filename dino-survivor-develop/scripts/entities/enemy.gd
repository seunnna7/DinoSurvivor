extends CharacterBody2D
class_name Enemy
## 몹 로직 (마일스톤 G2 개편)
## 씬은 이 하나뿐이고, EnemyStageData(티어+단계 데이터)를 주입받아 종류를 결정합니다.
## 스탯을 코드에 하드코딩하지 않았기 때문에, 새 몹은 코드 수정 없이 데이터 파일만 추가하면 됩니다.

const CONTACT_DAMAGE_INTERVAL := 0.5
const KNOCKBACK_DECAY := 8.0     ## 넉백 속도가 초당 이 배율로 감쇠 (move_toward 계수)
const BLEED_TICK_INTERVAL := 0.5 ## 출혈 데미지가 이 간격으로 나뉘어 들어감

var stage_data: EnemyStageData
var health: float

var _player: Node2D
var _contact_timer: float = 0.0

var _knockback_velocity: Vector2 = Vector2.ZERO
var _knockback_timer: float = 0.0

var _bleed_damage_per_tick: float = 0.0
var _bleed_timer: float = 0.0
var _bleed_tick_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	_player = get_tree().get_first_node_in_group("player")

## WaveManager가 스폰 직후 반드시 호출해줘야 합니다.
func setup(data: EnemyStageData) -> void:
	stage_data = data
	health = data.max_health
	scale *= data.visual_scale
	var visual := get_node_or_null("Visual")
	if visual != null:
		visual.color = data.visual_color

func _physics_process(delta: float) -> void:
	if _player == null or stage_data == null:
		return
	if _knockback_timer > 0.0:
		_knockback_timer -= delta
		velocity = _knockback_velocity
		_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, stage_data.move_speed * KNOCKBACK_DECAY * delta)
	else:
		velocity = global_position.direction_to(_player.global_position) * stage_data.move_speed
	move_and_slide()

	_contact_timer -= delta
	if _contact_timer <= 0.0 and _is_touching_player():
		_contact_timer = CONTACT_DAMAGE_INTERVAL
		if _player.has_method("take_damage"):
			_player.take_damage(stage_data.contact_damage)

	_process_bleed(delta)

## 넉백 부여. 넉백 중에는 플레이어를 향한 평소 추적 이동을 멈추고 knockback_velocity를 그대로 씀 —
## 시간이 지날수록 KNOCKBACK_DECAY 배율로 감속하다 duration 후 평소 추적으로 복귀.
## 철퇴처럼 밀어내는 공격이 사용 (기획 3.2: 상태이상 전달은 BaseAttackObject._on_hit_enemy 훅에서).
func apply_knockback(direction: Vector2, force: float, duration: float = 0.25) -> void:
	_knockback_velocity = direction.normalized() * force
	_knockback_timer = duration

## 출혈(지속 데미지) 부여. 이미 걸려 있으면 최신 수치로 덮어씀(중첩 대신 갱신 — 스택 관리는
## 필요해지면 Array[Dictionary]로 확장). 무리 사냥 진화 A가 사용.
func apply_bleed(damage_per_second: float, duration: float) -> void:
	_bleed_damage_per_tick = damage_per_second * BLEED_TICK_INTERVAL
	_bleed_timer = duration
	_bleed_tick_timer = 0.0  # 다음 _process_bleed 호출에서 즉시 1틱

func _process_bleed(delta: float) -> void:
	if _bleed_timer <= 0.0:
		return
	_bleed_timer -= delta
	_bleed_tick_timer -= delta
	if _bleed_tick_timer <= 0.0:
		_bleed_tick_timer = BLEED_TICK_INTERVAL
		take_damage(_bleed_damage_per_tick)

## move_and_slide()가 실제로 감지한 물리 충돌 중 플레이어와 맞닿은 게 있는지 확인.
## 콜리전 셰이프 반지름 합(플레이어 16 + 몹 12 등)이 몹마다(visual_scale) 달라지므로,
## 고정된 거리 상수 대신 실제 충돌 결과를 써야 정확합니다.
func _is_touching_player() -> bool:
	for i in get_slide_collision_count():
		if get_slide_collision(i).get_collider() == _player:
			return true
	return false

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		_die()

func _die() -> void:
	if stage_data != null and stage_data.loot_table != null:
		stage_data.loot_table.roll(get_parent(), global_position)
	queue_free()
