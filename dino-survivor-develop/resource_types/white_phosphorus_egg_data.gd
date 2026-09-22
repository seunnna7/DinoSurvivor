class_name WhitePhosphorusEggData
extends BaseSkillData
## 백린란(합체 결과) 전용 데이터. 알 폭탄 진화A(특란)처럼 포물선으로 던져(BaseLobbedProjectile
## 상속) 착탄 시 즉시 폭발하고, 그 자리에 침 뱉기 장판(VenomSpitZone)과 동일한 방식의
## 지속 화염 장판을 남깁니다 — 즉발 폭발 + 지속 장판의 이중 구조(스킬설계.md 3장).
##
## 합체 결과 스킬은 만렙=Lv1로 고정 장착되고 이후 레벨업이 없으므로(기획서 4.3),
## 다른 스킬처럼 레벨별 배열 대신 단일 수치로 정의합니다.

@export_group("투척")
@export var throw_range: float = 260.0
@export var min_flight_time: float = 0.4
@export var max_flight_time: float = 0.75

@export_group("폭발")
@export var aoe_radius: float = 140.0

@export_group("지속 화염 장판")
@export var zone_radius: float = 100.0
@export var zone_duration: float = 5.0
@export var tick_interval: float = 0.5
@export var zone_damage_ratio: float = 0.35  ## 장판 틱 데미지 = 폭발 데미지 * 이 비율
