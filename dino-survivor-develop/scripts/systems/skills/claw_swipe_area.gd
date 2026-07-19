class_name ClawSwipeArea
extends BaseAreaEffect
## 무리 사냥의 발톱 할퀴기 자국. 기본형은 스폰 즉시 1회 타격 후 페이드하는 BaseAreaEffect의
## 기본 동작을 그대로 씁니다. 진화 A(비열한 협공)일 때만 PackHuntSkill이 tick_interval/duration을
## 다단히트용 값으로 채워서 넘겨주고, 여기서는 "맞을 때마다 출혈도 함께 건다"는 것만 추가합니다.
## bleed_damage_per_second가 0이면(기본형) 출혈 없이 순수 데미지만 들어갑니다.

@export var bleed_damage_per_second: float = 0.0
@export var bleed_duration: float = 0.0

func _on_tick_hit(enemy: Enemy) -> void:
	if bleed_damage_per_second > 0.0:
		enemy.apply_bleed(bleed_damage_per_second, bleed_duration)
