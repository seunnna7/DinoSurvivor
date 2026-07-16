class_name Player
extends CharacterBody2D
## 플레이어 이동/체력 스크립트 (마일스톤 G1, G4에서 스탯 체계 연동, G7에서 피격/무적/사망 연동)
##
## Godot 팁: @export로 선언한 변수는 에디터 우측 Inspector 창에 노출됩니다.
## 코드를 몰라도 이 값들을 직접 조정할 수 있어서, 서브 개발자의 튜닝 포인트로 쓰기 좋습니다.

const INVINCIBILITY_DURATION := 0.5  ## 피격 후 무적 지속 시간
const FLICKER_INTERVAL := 0.08        ## 무적 중 스프라이트 깜빡임 주기

signal health_changed(current: float, max_health: float)  ## 체력바 UI가 구독
signal died                                                 ## 게임오버 UI가 구독

@export var species: SpeciesData  ## 인스펙터에서 trex.tres 등을 지정. 프로토타입은 티라노 고정.

var health: float
var max_health: float
var effective_move_speed: float  ## 종족 패시브 등 모디파이어가 반영된 최종 이동속도 (기획서 6.4)
var damage_multiplier: float = 1.0  ## 메타 강화(공격력) 등이 반영된 데미지 배율. SkillInstanceBase가 데미지 계산에 곱함
var facing_direction: Vector2 = Vector2.RIGHT  ## 마지막으로 이동한 방향. 철퇴처럼 방향성 있는 스킬이 조준 기준으로 사용.

var is_invincible: bool = false
var _invincibility_timer: float = 0.0
var _flicker_timer: float = 0.0

@onready var visual: ColorRect = $Visual

func _ready() -> void:
	add_to_group("player")  # WaveManager/Enemy가 플레이어를 찾을 때 이 그룹을 사용
	_recalculate_stats()
	max_health = StatCalculator.compute(StatTypes.DEFAULT_VALUE[&"max_health"], &"max_health", _modifiers())
	health = max_health
	health_changed.emit(health, max_health)

## 종족 패시브 + 메타 강화에서 나온 StatModifierData를 모아 실제 스탯에 반영.
## 지금은 이 둘만 반영하지만, 나중에 스탠스/숙련도도 같은 배열에 더하면 됩니다.
func _recalculate_stats() -> void:
	var base_speed: float = StatTypes.DEFAULT_VALUE[&"move_speed"]
	effective_move_speed = StatCalculator.compute(base_speed, &"move_speed", _modifiers())
	damage_multiplier = StatCalculator.compute(StatTypes.DEFAULT_VALUE[&"damage_mult"], &"damage_mult", _modifiers())

func _modifiers() -> Array[StatModifierData]:
	var mods: Array[StatModifierData] = []
	if species != null:
		mods.append_array(species.passive_modifiers)
	mods.append_array(MetaProgress.get_modifiers())
	return mods

func _physics_process(delta: float) -> void:
	# ui_left / ui_right / ui_up / ui_down 은 Godot 기본 내장 입력(방향키)입니다.
	# WASD로 바꾸고 싶다면: 프로젝트 설정(Project > Project Settings) > Input Map 탭에서
	# 각 액션에 W/A/S/D 키를 추가로 등록하면 됩니다.
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * effective_move_speed
	move_and_slide()
	if input_dir != Vector2.ZERO:
		facing_direction = input_dir.normalized()
	_process_invincibility(delta)

func _process_invincibility(delta: float) -> void:
	if not is_invincible:
		return
	_invincibility_timer -= delta
	_flicker_timer -= delta
	if _flicker_timer <= 0.0:
		_flicker_timer = FLICKER_INTERVAL
		visual.visible = not visual.visible
	if _invincibility_timer <= 0.0:
		is_invincible = false
		visual.visible = true

func take_damage(amount: float) -> void:
	if is_invincible or health <= 0.0:
		return
	health = maxf(health - amount, 0.0)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		died.emit()
		return
	is_invincible = true
	_invincibility_timer = INVINCIBILITY_DURATION
	_flicker_timer = 0.0
