class_name KnockbackSystem
extends RefCounted
## 넉백 수치 계산 전담 유틸리티(StatCalculator와 동일한 패턴 — 상태 없는 순수 계산만 제공).
## Enemy는 이 결과를 외력(external force)으로 "적용"만 하고, "비율 → 실제 px/속도" 변환
## 공식은 전부 여기 있습니다.
##
## 지속시간(DURATION)은 모든 넉백에 공통으로 고정합니다 — 거리가 커져도 지속시간은 늘지
## 않고 속도만 커집니다. "더 세게 맞으면 더 멀리 밀려나되, 밀려나는 시간 자체는 항상
## 똑같다"는 예측 가능한 감각을 기획 예측성보다 물리적 엄밀함보다 우선한 설계 결정.

const TILE_PX := 32.0     ## 캐릭터 한 칸 = Player 충돌 지름(반지름 16 × 2, Player.tscn)과 일치
const DURATION := 0.12    ## 모든 넉백 공통 지속시간(초). 시스템 고정값 — 기획자는 건드리지 않음

## knockback_distance(비율) + 적의 knockback_resistance(0~1)로 저항 적용 후 실제 px 거리를 계산.
static func actual_distance_px(knockback_distance: float, knockback_resistance: float) -> float:
	return knockback_distance * TILE_PX * (1.0 - clampf(knockback_resistance, 0.0, 1.0))

## 위 실제 거리를 DURATION 안에 정확히 0까지 선형 감쇠시키는 데 필요한 초기 속도(px/s).
static func initial_speed(distance_px: float) -> float:
	return 2.0 * distance_px / DURATION
