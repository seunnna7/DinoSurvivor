extends CharacterBody2D
class_name Enemy
## 몹 로직 (마일스톤 G2 개편)
## 씬은 이 하나뿐이고, EnemyStageData(티어+단계 데이터)를 주입받아 종류를 결정합니다.
## 스탯을 코드에 하드코딩하지 않았기 때문에, 새 몹은 코드 수정 없이 데이터 파일만 추가하면 됩니다.

const CONTACT_DAMAGE_INTERVAL := 0.5
const MAX_EXTERNAL_SPEED := 900.0 ## 외력(넉백/견인 등)이 합성돼도 넘지 못하는 속도 상한
const BLEED_TICK_INTERVAL := 0.5 ## 출혈 데미지가 이 간격으로 나뉘어 들어감

var stage_data: EnemyStageData
var health: float

var _player: Node2D
var _contact_timer: float = 0.0

## "적의 의지와 무관하게 강제로 미는" 모든 힘의 공통 상태 — 지금은 넉백만 이 채널을 쓰지만,
## 나중에 견인/흡입/컨베이어 같은 다른 외력이 생겨도 apply_external_force() 하나로 얹으면 됨.
var _external_velocity: Vector2 = Vector2.ZERO
var _external_force_timer: float = 0.0

var _bleed_damage_per_tick: float = 0.0
var _bleed_timer: float = 0.0
var _bleed_tick_timer: float = 0.0

var _slow_multiplier: float = 1.0 ## 이동속도에 곱해지는 배율. 1.0 = 감속 없음(기본)
var _slow_timer: float = 0.0

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
	if _external_force_timer > 0.0:
		var decay_fraction := clampf(delta / _external_force_timer, 0.0, 1.0)
		_external_velocity -= _external_velocity * decay_fraction
		_external_force_timer -= delta
		velocity = _external_velocity
	else:
		velocity = global_position.direction_to(_player.global_position) * stage_data.move_speed * _slow_multiplier
	move_and_slide()

	_contact_timer -= delta
	if _contact_timer <= 0.0 and _is_touching_player():
		_contact_timer = CONTACT_DAMAGE_INTERVAL
		if _player.has_method("take_damage"):
			_player.take_damage(stage_data.contact_damage)

	_process_bleed(delta)
	_process_slow(delta)

## 외력(external force) 부여. 넉백뿐 아니라 나중에 추가될 견인/흡입/컨베이어 등 "적의 의지와
## 무관하게 강제로 미는" 모든 효과의 공통 진입점. 여러 외력이 동시에 걸리면 벡터 합으로
## 자연스럽게 합성되고(덮어쓰지 않음), MAX_EXTERNAL_SPEED로만 클램프합니다. 지속시간은 더 긴
## 쪽을 우선(기존 힘이 아직 안 끝났는데 더 짧은 새 힘이 덮어써서 일찍 끝나버리지 않도록).
## 외력이 걸린 동안에는 평소 추적 이동을 멈추고 이 힘을 그대로 쓰다, 끝나면 즉시 복귀합니다.
func apply_external_force(added_velocity: Vector2, duration: float) -> void:
	_external_velocity = (_external_velocity + added_velocity).limit_length(MAX_EXTERNAL_SPEED)
	_external_force_timer = maxf(_external_force_timer, duration)

## take_damage()가 knockback_distance > 0일 때 호출. 비율 → 저항 적용 실제 px 거리 → 속도
## 변환은 전부 KnockbackSystem이 계산하고, 여기서는 결과를 external force로 적용만 합니다.
## 방향은 항상 "공격 중심(source_position) → 적 중심" (Direction Rule과 무관한 별개 규칙).
func _apply_knockback(knockback_distance: float, source_position: Vector2) -> void:
	var actual_px := KnockbackSystem.actual_distance_px(knockback_distance, stage_data.knockback_resistance)
	if actual_px <= 0.0:
		return
	var direction := source_position.direction_to(global_position)
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	apply_external_force(direction * KnockbackSystem.initial_speed(actual_px), KnockbackSystem.DURATION)

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

## 이동속도 감소(둔화) 부여. 이미 걸려 있으면 최신 수치로 덮어씀(출혈과 동일한 정책 —
## apply_bleed() 참고). 침 뱉기 진화 A(맹독지대)가 사용.
func apply_slow(speed_multiplier: float, duration: float) -> void:
	_slow_multiplier = speed_multiplier
	_slow_timer = duration

func _process_slow(delta: float) -> void:
	if _slow_timer <= 0.0:
		return
	_slow_timer -= delta
	if _slow_timer <= 0.0:
		_slow_multiplier = 1.0

## move_and_slide()가 실제로 감지한 물리 충돌 중 플레이어와 맞닿은 게 있는지 확인.
## 콜리전 셰이프 반지름 합(플레이어 16 + 몹 12 등)이 몹마다(visual_scale) 달라지므로,
## 고정된 거리 상수 대신 실제 충돌 결과를 써야 정확합니다.
func _is_touching_player() -> bool:
	for i in get_slide_collision_count():
		if get_slide_collision(i).get_collider() == _player:
			return true
	return false

## knockback_distance/source_position은 옵션(기본값=넉백 없음) — 공격 데이터에 knockback_distance가
## 없으면 그냥 데미지만 들어갑니다(넉백은 공격의 선택적 속성). source_position은 "공격 중심"으로,
## 넉백 방향은 항상 이 지점 → 적 중심입니다.
func take_damage(amount: float, knockback_distance: float = 0.0, source_position: Vector2 = global_position) -> void:
	health -= amount
	if knockback_distance > 0.0:
		_apply_knockback(knockback_distance, source_position)
	if health <= 0:
		_die()

func _die() -> void:
	if stage_data != null and stage_data.loot_table != null:
		stage_data.loot_table.roll(get_parent(), global_position)
	queue_free()
