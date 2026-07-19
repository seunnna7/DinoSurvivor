class_name BaseProjectile
extends BaseAttackObject
## 발사형 스킬 전반이 공유하는 투사체. 데미지 전달의 기본 계약은 부모(BaseAttackObject)가
## 처리하고, 여기서는 "이동 + 사거리 판정"이라는 발사형 고유의 배관만 추가합니다.
## 하위 클래스는 아래 3개 가상 함수만 오버라이드하면 됩니다:
##   _on_travel(delta)     : 매 물리 프레임, 이동 이후에 호출 (도탄 판정, 경로 이벤트 체크 등)
##   _on_hit_enemy(enemy)  : Enemy와 겹쳤을 때 호출 (기본: 데미지 주고 소멸 = 비관통)
##   _on_range_reached()   : max_distance만큼 이동을 마쳤을 때 호출 (기본: 소멸)
## 새 발사형 스킬(예: 화염구, 유도탄)은 이 클래스를 상속해 필요한 훅만 재정의하면 됩니다.

@export var speed: float = 400.0
@export var max_distance: float = 300.0

var direction: Vector2 = Vector2.RIGHT
var origin: Vector2 = Vector2.ZERO

var _traveled_distance: float = 0.0
var _is_expired: bool = false

## 스폰 직후 호출. 시작 위치와 진행 방향을 설정하고, 스프라이트를 진행 방향으로 회전시킵니다.
func launch(from_position: Vector2, in_direction: Vector2) -> void:
	origin = from_position
	global_position = from_position
	direction = in_direction.normalized()
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	if _is_expired:
		return
	var motion := direction * speed * delta
	global_position += motion
	_traveled_distance += motion.length()
	_on_travel(delta)
	if not _is_expired and _traveled_distance >= max_distance:
		_on_range_reached()

## 하위 클래스 오버라이드용. 매 물리 프레임 이동 직후 호출.
func _on_travel(_delta: float) -> void:
	pass

## 소멸 후에는 더 이상 충돌을 처리하지 않도록 부모(BaseAttackObject)의 처리 전에 가드만 추가.
func _on_body_entered(body: Node2D) -> void:
	if _is_expired:
		return
	super._on_body_entered(body)

## 기본 동작: 데미지를 입히고 즉시 소멸(비관통 투사체). 관통형은 이 함수를 오버라이드해서
## _despawn() 호출을 생략하면 됩니다(깃털 다트가 이렇게 함).
func _on_hit_enemy(enemy: Enemy) -> void:
	enemy.take_damage(damage)
	_despawn()

## 하위 클래스 오버라이드용. 기본 동작: 사거리 소진 시 그냥 소멸(AOE 없음).
func _on_range_reached() -> void:
	_despawn()

func _despawn() -> void:
	if _is_expired:
		return
	_is_expired = true
	queue_free()
