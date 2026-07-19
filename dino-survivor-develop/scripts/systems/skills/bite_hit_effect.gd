class_name BiteHitEffect
extends BaseAttackObject
## 물기 판정 이펙트. TopJaw/BottomJaw는 같은 위치에 겹쳐진 7프레임 스프라이트 시트
## (bite_top.png/bite_bottom.png, 각 프레임 32x34, 열린 입 → 닫히는 입)이고, 별도의
## 이동 트윈 없이 AnimationPlayer가 두 스프라이트의 frame 값(0~6)을 같은 타이밍에
## 한 프레임씩 순차 재생합니다. "bite" 애니메이션의 메서드 콜 트랙이 5번째 프레임
## (frame == 4, 입이 완전히 닫히는 시점)에서 _on_jaws_closed()를 딱 1회 호출하고,
## 그 순간에만 히트박스 범위 안의 모든 적에게 광역 데미지가 들어갑니다.
##
## body_entered(물리 충돌)로는 데미지를 주지 않도록 monitoring을 꺼둡니다 — 스폰되자마자
## 스치기만 해도 맞는 게 아니라, 애니메이션이 정한 "씹는 타이밍"에만 판정되게 하기 위함입니다.
##
## 히트박스는 CircleShape2D가 아니라 RectangleShape2D이고, 크기는 항상 스프라이트 프레임
## 크기(FRAME_SIZE, 32x34)와 정확히 같습니다 — 즉 히트박스 = 화면에 그려지는 이미지의
## 경계 그 자체. "범위를 키운다"는 이 노드 전체의 scale을 키운다는 뜻이라, 이미지와
## 히트박스가 항상 같은 크기로 함께 커집니다. 그 scale 계산은 _apply_range_scale() 한
## 곳에서만 담당합니다.

## bite_top/bite_bottom 프레임 한 장의 크기(px, 원본 텍스처 기준). 히트박스(RectangleShape2D)
## 크기의 기준값 — 이 노드가 scale 1일 때 히트박스와 스프라이트가 정확히 이 크기로 겹칩니다.
const FRAME_SIZE := Vector2(32.0, 34.0)

## 물기 범위가 늘어날 때(아이템/레벨업 등) BiteSkill이 이 값만 키워서 넘기면
## _apply_range_scale()이 히트박스와 TopJaw/BottomJaw 스프라이트를 항상 같은 크기로
## 함께 키웁니다.
@export var range_scale: float = 5.0

## 원하는 판정 "가로" 길이(px, range_scale 적용 전). FRAME_SIZE.x(32) 대비 몇 배로
## 늘려 그릴지를 정하는 기준값 — BiteSkill이 스폰 전에 MeleeSkillData.range_for_level()을
## 지름으로 환산해 채워줍니다. (세로는 FRAME_SIZE 비율에 맞춰 함께 늘어남)
@export var base_width: float = 160.0

## 이펙트가 향하는 방향(턱 스프라이트 + 히트박스 회전에 사용). BiteSkill이 스폰 전에
## 가장 가까운 적 방향으로 채워줍니다.
var facing: Vector2 = Vector2.RIGHT

@onready var _anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	super._ready()
	monitoring = false
	rotation = facing.angle()
	_apply_range_scale(range_scale)
	_anim.animation_finished.connect(func(_anim_name): queue_free())
	_anim.play(&"bite")

## 히트박스 크기와 이펙트 스프라이트 확대를 한곳에서 같이 관리하는 함수. 스프라이트와
## 히트박스 모두 이 노드(Area2D)의 자식이라 node.scale 하나로 똑같이 커지고, 히트박스
## RectangleShape2D의 크기는 항상 FRAME_SIZE 그대로 두기 때문에(스케일이 알아서 키움)
## 이미지 경계와 히트박스가 절대 어긋나지 않습니다. 물기 범위가 늘어날 일이 생기면
## 여기 말고 range_scale로 들어오는 값만 키우면 됩니다.
func _apply_range_scale(new_scale: float) -> void:
	range_scale = new_scale
	var reach_scale := base_width / FRAME_SIZE.x
	scale = Vector2.ONE * reach_scale * range_scale
	_sync_collision_rect(FRAME_SIZE)

## AnimationPlayer 메서드 콜 트랙 전용 콜백 — "bite" 애니메이션의 입이 닫히는 키프레임에서
## 정확히 1회 호출됩니다. 그 순간 히트박스(월드 공간 크기 = FRAME_SIZE * scale, 즉 화면에
## 보이는 이미지 경계와 동일) 안의 모든 적을 한꺼번에 타격하는 광역 판정.
func _on_jaws_closed() -> void:
	_deal_aoe_damage_box(global_position, rotation, FRAME_SIZE * scale, damage)
