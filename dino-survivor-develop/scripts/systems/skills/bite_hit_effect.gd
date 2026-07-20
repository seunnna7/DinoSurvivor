class_name BiteHitEffect
extends BaseAttackObject
## 물기 판정 이펙트. TopJaw/BottomJaw는 같은 위치에 겹쳐진 7프레임 스프라이트 시트
## (bite_top.png/bite_bottom.png, 각 프레임 32x34, 열린 입 → 닫히는 입)이고, 별도의
## 이동 트윈 없이 AnimationPlayer가 두 스프라이트의 frame 값(0~6)을 같은 타이밍에
## 한 프레임씩 순차 재생합니다. "bite" 애니메이션의 메서드 콜 트랙이 5번째 프레임
## (frame == 4, 입이 완전히 닫히는 시점)에서 _on_jaws_closed()를 딱 1회 호출하고,
## 그 순간에만 히트박스 범위 안의 모든 적에게 광역 데미지가 들어갑니다.
##
## 방향 표현(Direction Rule: Fixed Direction): 각도에 상관없이 회전(rotation)은 항상 0으로
## 고정 — 스프라이트와 히트박스 모두 절대 회전시키지 않습니다. 대신 스폰 순간의
## facing_direction을 스냅샷으로 고정해두고(발동 이후 방향 자체는 바뀌지 않음), facing_direction.x가
## 왼쪽이면 스프라이트를 그대로, 오른쪽이면 좌우반전(flip_h)만 적용합니다.
##
## 위치는 방향과 별개로 계속 갱신됩니다 — 매 프레임 owner_body(플레이어) 위치 + facing_direction *
## reach로 재계산해서, 씹는 애니메이션이 끝나기 전에 플레이어가 움직여도 이펙트가 항상 플레이어
## 앞에 붙어 따라갑니다.
##
## body_entered(물리 충돌)로는 데미지를 주지 않도록 monitoring을 꺼둡니다 — 스폰되자마자
## 스치기만 해도 맞는 게 아니라, 애니메이션이 정한 "씹는 타이밍"에만 판정되게 하기 위함입니다.
##
## "사거리"(플레이어 앞으로 얼마나 나가서 스폰될지 정하는 reach, BiteSkill._fire() 담당)와
## "이 판정 자체의 물리적 크기"는 서로 다른 개념이라 하나로 묶지 않습니다. 이 노드는 scale을
## 건드리지 않고 항상 기준 해상도(scale=1) 그대로 유지합니다 — 스프라이트는 원본 텍스처
## 픽셀 크기(32x34) 그대로 그려지고, 히트박스는 그와 별개로 HITBOX_SIZE 고정 크기입니다.

## 물기 판정의 물리적 크기(px, 기준 해상도 기준 고정값). 스프라이트 프레임 크기(32x34)와는
## 별개 — 실제 "이빨이 맞물리는" 영역만큼만 잡은 값이라 스프라이트보다 작습니다.
const HITBOX_SIZE := Vector2(120.0, 60.0)

## 발동 순간에 고정된 방향(플레이어 facing_direction 스냅샷). BiteSkill이 스폰 전에 채워주며,
## 발동 이후에는 바뀌지 않습니다(Fixed Direction 규칙 — 방향은 시전 순간에만 결정).
var facing_direction: Vector2 = Vector2.RIGHT

## 플레이어 위치에서 facing_direction으로 얼마나 앞에 이펙트가 스폰되는지(px).
## BiteSkill이 MeleeSkillData.range_for_level()로 채웁니다.
var reach: float = 0.0

## 위치를 계속 따라갈 기준 캐릭터(플레이어). BiteSkill이 스폰 전에 채워줍니다.
var owner_body: Node2D = null

@onready var _top_jaw: Sprite2D = $TopJaw
@onready var _bottom_jaw: Sprite2D = $BottomJaw
@onready var _anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	super._ready()
	monitoring = false
	rotation = 0.0
	_sync_collision_rect(HITBOX_SIZE)
	var flip_h := facing_direction.x > 0.0
	_top_jaw.flip_h = flip_h
	_bottom_jaw.flip_h = flip_h
	_track_owner()
	_anim.animation_finished.connect(func(_anim_name): queue_free())
	_anim.play(&"bite")

func _process(_delta: float) -> void:
	_track_owner()

## owner_body(플레이어)의 현재 위치 + 고정된 facing_direction * reach로 이펙트 위치를 갱신.
func _track_owner() -> void:
	if owner_body != null:
		global_position = owner_body.global_position + facing_direction * reach

## AnimationPlayer 메서드 콜 트랙 전용 콜백 — "bite" 애니메이션의 입이 닫히는 키프레임에서
## 정확히 1회 호출됩니다. 그 순간 HITBOX_SIZE 크기의 히트박스 안에 있는 모든 적을 한꺼번에
## 타격하는 광역 판정(회전 없이 축 정렬된 사각형).
func _on_jaws_closed() -> void:
	_deal_aoe_damage_box(global_position, 0.0, HITBOX_SIZE, damage)
