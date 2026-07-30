class_name ClawSwipeArea
extends BaseAreaEffect
## 무리 사냥의 발톱 할퀴기 자국. 기본형은 스폰 즉시 1회 타격 후 페이드하는 BaseAreaEffect의
## 기본 동작을 그대로 씁니다. 진화 A(비열한 협공)일 때만 PackHuntSkill이 tick_interval/duration을
## 다단히트용 값으로 채워서 넘겨주고, 여기서는 "맞을 때마다 출혈도 함께 건다"는 것만 추가합니다.
## bleed_damage_per_second가 0이면(기본형) 출혈 없이 순수 데미지만 들어갑니다.
##
## 시각적으로는 pack_hunt_sprite-Sheet.png(7프레임 할퀸 자국)를 "swipe" 애니메이션으로 재생해
## 순간적으로 할퀴는 모션을 표현하고, 이후 남은 duration 동안은 BaseAreaEffect의 기본 페이드로
## 마지막 프레임이 서서히 옅어지며 사라집니다.

@export var bleed_damage_per_second: float = 0.0
@export var bleed_duration: float = 0.0

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	super._ready()
	_sprite.flip_h = randf() < 0.5
	_anim.play(&"swipe", -1, 0.5)

func _on_tick_hit(enemy: Enemy) -> void:
	if bleed_damage_per_second > 0.0:
		enemy.apply_bleed(bleed_damage_per_second, bleed_duration)
