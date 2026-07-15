extends Node
## Autoload 싱글톤. data/enemies/의 EnemyStageData를 티어별로 관리하며 스폰합니다.
##
## - NORMAL / ELITE: 각 티어의 "현재 활성 단계"가 가진 spawn_interval에 따라 반복 스폰
## - BOSS: 해당 단계의 unlock_time에 딱 1회만 스폰 (반복 없음)
##
## 몹을 추가/변경할 때 이 스크립트는 건드릴 필요 없습니다 — data/enemies/ 폴더만 갱신하면 됩니다.

const ENEMIES_PATH := "res://data/enemies/"
const SPAWN_DISTANCE := 500.0
const ENEMY_SCENE := preload("res://scenes/entities/Enemy.tscn")

var _stages_by_tier: Dictionary = {}   # Tier(int) -> Array[EnemyStageData], stage 오름차순
var _tier_timers: Dictionary = {}      # Tier(int) -> float
var _spawned_bosses: Dictionary = {}   # stage.id -> bool

var _player: Node2D = null
var _enemy_container: Node = null
var _running: bool = false

func _ready() -> void:
	_load_stages()

func _load_stages() -> void:
	var dir := DirAccess.open(ENEMIES_PATH)
	if dir == null:
		push_warning("몹 데이터 폴더를 찾을 수 없습니다: %s" % ENEMIES_PATH)
		return

	var all: Array[EnemyStageData] = []
	for file_name in dir.get_files():
		if file_name.ends_with(".tres"):
			all.append(load(ENEMIES_PATH + file_name))

	for tier in [EnemyStageData.Tier.NORMAL, EnemyStageData.Tier.ELITE, EnemyStageData.Tier.BOSS]:
		var list: Array[EnemyStageData] = all.filter(func(s): return s.tier == tier)
		list.sort_custom(func(a, b): return a.stage < b.stage)
		_stages_by_tier[tier] = list
		_tier_timers[tier] = 0.0

func start(player: Node2D, enemy_container: Node) -> void:
	_player = player
	_enemy_container = enemy_container
	_running = true

func stop() -> void:
	_running = false

func _process(delta: float) -> void:
	if not _running or _player == null or _enemy_container == null:
		return
	RunState.elapsed_time += delta
	_process_recurring(EnemyStageData.Tier.NORMAL, delta)
	_process_recurring(EnemyStageData.Tier.ELITE, delta)
	_process_boss()

## 현재 시간 기준으로 해당 티어에서 "활성화된 가장 높은 단계"를 반환.
## 예: unlock_time이 0/90/180인 단계 3개가 있으면, 95초 시점엔 90초짜리가 선택됨.
func _current_stage(tier: int) -> EnemyStageData:
	var chosen: EnemyStageData = null
	for s in _stages_by_tier.get(tier, []):
		if RunState.elapsed_time >= s.unlock_time:
			chosen = s
		else:
			break
	return chosen

func _process_recurring(tier: int, delta: float) -> void:
	var stage := _current_stage(tier)
	if stage == null:
		return
	_tier_timers[tier] -= delta
	if _tier_timers[tier] <= 0.0:
		_tier_timers[tier] = stage.spawn_interval
		for i in stage.spawn_count_per_tick:
			_spawn(stage)

func _process_boss() -> void:
	var stage := _current_stage(EnemyStageData.Tier.BOSS)
	if stage == null:
		return
	if _spawned_bosses.get(stage.id, false):
		return
	_spawned_bosses[stage.id] = true
	_spawn(stage)

func _spawn(stage: EnemyStageData) -> void:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	_enemy_container.add_child(enemy)  # global_position은 트리에 들어간 뒤에 설정해야 정확함
	var angle := randf() * TAU
	enemy.global_position = _player.global_position + Vector2.RIGHT.rotated(angle) * SPAWN_DISTANCE
	enemy.setup(stage)
