class_name MaceSlamImpact
extends BaseAreaEffect
## 철퇴 진화 B(내려찍기)의 착지 충격파. BaseAreaEffect가 스폰 즉시 반경 안의 적을
## 스캔해서 데미지를 주는 것까지는 그대로 쓰고, 여기서는 "맞은 적을 강하게 밀어낸다"는
## 내려찍기 고유의 넉백만 추가합니다. damage/radius/duration은 MaceSkill이 스폰 직후 채워줍니다.

@export var knockback_force: float = 420.0
@export var knockback_duration: float = 0.3

func _on_tick_hit(enemy: Enemy) -> void:
	var direction := global_position.direction_to(enemy.global_position)
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	enemy.apply_knockback(direction, knockback_force, knockback_duration)
