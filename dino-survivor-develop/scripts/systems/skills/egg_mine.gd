class_name EggMine
extends BaseAttackObject
## 알 폭탄 진화 B(알다발)가 착탄 지점 주변에 흩뿌리는 미니 알(LOL 직스 E 컨셉).
## 평소엔 가만히 있다가 적이 닿으면(body_entered) 그 즉시 스스로 터져서 반경 radius 안의
## 적에게 데미지를 주고 사라집니다. lifetime 동안 아무도 안 밟으면 자동으로 소멸합니다.

@export var radius: float = 30.0
@export var lifetime: float = 6.0

var _exploded: bool = false

func _ready() -> void:
	super._ready()
	_sync_collision_radius(radius)

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

## 밟은 그 즉시 폭발 — 밟은 적 하나만이 아니라 반경 안의 모두를 휩쓴다는 게 일반 지뢰와의 차이.
func _on_hit_enemy(enemy: Enemy) -> void:
	if _exploded:
		return
	_exploded = true
	_deal_aoe_damage(global_position, radius, damage)
	queue_free()
