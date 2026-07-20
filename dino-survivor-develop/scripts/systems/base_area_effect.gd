class_name BaseAreaEffect
extends BaseAttackObject
## 장판형(범위) 공격의 공통 로직. 스폰 즉시 반경 radius 안의 적을 1회 스캔해서 타격하고,
## duration 동안 유지되다 사라집니다. 시각적으로는 남은 시간에 비례해 modulate.a(투명도)를
## 서서히 낮춰서 "옅어지다 사라지는" 페이드를 기본 제공합니다 — 더 화려한 연출이 필요하면
## 하위 씬에서 자체 Tween을 추가해도 되고, 이 기본 페이드만으로도 충분합니다.
##
##   tick_interval == 0.0 (기본) : 스폰 순간 1회만 타격하고 이후로는 순수 시각 효과로만 존재.
##                                  예: 무리 사냥 기본형(할퀴고 사라짐).
##   tick_interval > 0.0         : duration 동안 겹쳐 있는 적을 이 간격으로 반복 타격(다단히트).
##                                  예: 무리 사냥 진화 A(출혈), 진화 B(지속 추적 영역).
##   move_speed > 0.0            : 매 프레임 가장 가까운 적 쪽으로 서서히 이동(추적형 영역).
##                                  예: 무리 사냥 진화 B.

@export var radius: float = 60.0
@export var duration: float = 0.6
@export var tick_interval: float = 0.0  ## 0이면 스폰 시 1회만 타격, >0이면 duration 동안 반복 타격
@export var move_speed: float = 0.0     ## 0이면 고정, >0이면 가장 가까운 적 쪽으로 이 속도로 이동

var _elapsed: float = 0.0
var _hit_timers: Dictionary = {}  ## Enemy -> float(다음 타격까지 남은 시간). tick_interval > 0일 때만 사용.

func _ready() -> void:
	super._ready()
	_sync_collision_radius(radius)
	_strike_all_overlapping()
	if tick_interval > 0.0:
		body_exited.connect(_on_body_exited)
	else:
		monitoring = false  # 스폰 시 1회 타격 후에는 충돌 판정 종료 — 이후엔 순수 페이드 연출만 남음

func _physics_process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= duration:
		queue_free()
		return
	modulate.a = 1.0 - (_elapsed / duration)  # 남은 시간에 비례해 서서히 옅어짐
	if move_speed > 0.0:
		_move_toward_nearest_enemy(delta)
	if tick_interval > 0.0:
		_process_ticks(delta)

## body_entered로 새로 겹친 적 처리. tick 모드면 타이머 등록만(다음 tick에 실제 타격),
## 그게 아니면(1회성) 즉시 타격 — 다만 1회성은 스폰 직후 monitoring을 꺼버리므로
## 이 경로는 사실상 "스폰된 바로 그 물리 프레임에 겹친 경우"에만 보조적으로 쓰입니다.
func _on_hit_enemy(enemy: Enemy) -> void:
	if tick_interval > 0.0:
		_hit_timers[enemy] = tick_interval
	else:
		enemy.take_damage(damage, knockback_distance, global_position)
		_on_tick_hit(enemy)

func _on_body_exited(body: Node2D) -> void:
	var enemy := body as Enemy
	if enemy != null:
		_hit_timers.erase(enemy)

## 스폰 시점 스냅샷 타격. Area2D의 body_entered 신호는 물리 프레임이 한 번 지나야 발생하므로,
## "나타나자마자 범위 안의 적을 때린다"는 요구를 만족하려면 이렇게 직접 거리로 스캔해야 합니다.
func _strike_all_overlapping() -> void:
	_deal_aoe_damage(global_position, radius, damage, _on_tick_hit)
	if tick_interval > 0.0:
		for node in get_tree().get_nodes_in_group("enemy"):
			var enemy := node as Enemy
			if enemy != null and global_position.distance_to(enemy.global_position) <= radius:
				_hit_timers[enemy] = tick_interval

func _process_ticks(delta: float) -> void:
	for enemy in _hit_timers.keys():
		if not is_instance_valid(enemy):
			_hit_timers.erase(enemy)  # body_exited가 도착하기 전에 다른 공격으로 이미 freed된 경우
			continue
		_hit_timers[enemy] -= delta
		if _hit_timers[enemy] <= 0.0:
			_hit_timers[enemy] = tick_interval
			enemy.take_damage(damage, knockback_distance, global_position)
			_on_tick_hit(enemy)

func _move_toward_nearest_enemy(delta: float) -> void:
	var nearest := _find_nearest_enemy()
	if nearest != null:
		global_position += global_position.direction_to(nearest.global_position) * move_speed * delta

## 하위 클래스 오버라이드용. 타격이 실제로 들어갈 때마다 호출(스폰 시 스냅샷 포함) — 출혈 등
## 상태이상 부여에 사용(예: 무리 사냥 진화 A가 이걸 오버라이드해서 enemy.apply_bleed() 호출).
func _on_tick_hit(_enemy: Enemy) -> void:
	pass
