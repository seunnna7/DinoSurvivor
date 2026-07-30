class_name VenomSpitZone
extends BaseAreaEffect
## 침 뱉기가 착탄 지점에 남기는 중독 장판. tick_interval 간격으로 반경 안의 적에게 데미지를
## 반복(기본형은 이것만으로 충분 — 별도 상태이상 없이 "장판 안에 있으면 계속 맞는다"가 곧 중독).
## 진화 A(맹독지대)만 slow_multiplier를 1.0 미만으로 채워서, 틱마다 적에게 이동속도 감소
## 디버프까지 추가로 건다(무리 사냥 진화 A가 출혈을 얹는 것과 동일한 패턴).

@export var slow_multiplier: float = 1.0  ## 1.0 = 감속 없음(기본형). 진화 A에서 1.0 미만으로 채워짐.
@export var slow_duration: float = 0.0    ## 감속 지속시간(진화 A 전용, 장판을 벗어나도 이 시간만큼 유지)

func _on_tick_hit(enemy: Enemy) -> void:
	if slow_multiplier < 1.0:
		enemy.apply_slow(slow_multiplier, slow_duration)
