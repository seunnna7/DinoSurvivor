class_name SkillData
extends Resource
## 스킬 하나를 정의하는 데이터 리소스.
## 새 스킬을 추가할 때 이 스크립트를 건드릴 필요 없이,
## 이 스키마를 기반으로 data/skills/ 안에 새 .tres 파일만 만들면 됩니다.
## (Godot 에디터에서 우클릭 > New Resource > SkillData 로 생성 가능)

enum Stance { QUADRUPED, BIPED, BOTH }
enum Category { ACTIVE, PASSIVE }  ## 태그와 별개인 대분류 (기획서 3.1). PASSIVE는 메인 런 화면 보유 스킬 HUD에 노출되지 않음

const DAMAGE_PLACEHOLDER := "(데미지_숫자)"  ## flavor_text 안에 이 문자열을 적어두면 description()이 base_damage로 치환

@export var id: StringName
@export var display_name: String
@export var species_motif: String
@export_multiline var flavor_text: String  ## 플레이버 텍스트 보이스 공식 적용 (기획서 4.1.1). DAMAGE_PLACEHOLDER를 넣어두면 카드에 실제 데미지가 채워짐

@export_group("분류")
@export var category: Category = Category.ACTIVE
@export var tags: Array[StringName] = []  ## 자유 태그 (예: "melee", "summon", "projectile", "bomb"). 스킬 변주 체크와 향후 태그 기반 버프("소환수 강화" 등)에 공용으로 사용
@export var preferred_stance: Stance = Stance.BOTH

@export_group("수치")
@export var base_damage: float = 10.0
@export var cooldown: float = 1.0
@export var max_level: int = 5  ## 진화(만렙) 기준 (기획서 4.3)

@export_group("넉백")
## 캐릭터 한 칸(32px)을 1.0 기준으로 한 비율. 0 = 넉백 없음. Damage/Hitbox와 완전히 독립된 값이라
## 서로 영향을 주지 않음(예: 고데미지+넉백없음, 저데미지+강한넉백 둘 다 표현 가능). 실제 px 거리/속도/
## 지속시간은 KnockbackSystem이 적 knockback_resistance를 반영해 계산 — 여기엔 비율만 적어두면 됨.
@export var knockback_distance: float = 0.0

@export_group("씬 참조")
@export var effect_scene: PackedScene  ## 투사체/이펙트 씬 (있는 경우)
@export var logic_scene: PackedScene   ## 이 스킬의 실제 동작을 구현한 로직 씬 (SkillInstanceBase 상속). 비어있으면 "더미"(UI에만 존재, 실제 동작 없음)

@export_group("진화")
@export var evolutions: Array[SkillData] = []  ## 이 스킬이 만렙(Lv5)에 도달했을 때 제시할 진화 선택지 (1~3개, 기획서 4.3/4.5). 진화형 SkillData는 이 배열을 가진 "베이스 스킬"과 달리 data/skill_evolutions/ 에 따로 보관하고 max_level=1로 설정 — 공용 풀(SkillDatabase)에는 스캔되지 않음

@export_group("패시브 효과")
@export var passive_modifiers: Array[StatModifierData] = []  ## category가 PASSIVE일 때만 사용. 각 항목의 stat_id에 점(.)이 있으면 "태그.효과필드"로 그 태그를 가진 액티브 스킬 전체를 겨냥(예: "projectile.range" → 투사체 태그 스킬 전부의 사거리 증가), 없으면 전역 스탯(기획서 6.4) 강화. 특정 스킬 하나를 직접 지정하는 MasteryMilestoneData.target("스킬id.수치필드")과는 좌변 의미가 다름 — 기획서 4.2.1

@export_group("표시")
@export var icon_color: Color = Color(0.8, 0.8, 0.8, 1.0)  ## 스킬 아이콘 자리표시용 색상 (실제 아이콘 이미지로 교체 전까지)

## 스킬 카드에 표시할 설명. flavor_text 그대로 쓰되, DAMAGE_PLACEHOLDER 자리에 실제 base_damage를 채워 넣습니다.
func description() -> String:
	return flavor_text.replace(DAMAGE_PLACEHOLDER, _format_number(base_damage))

## 스킬 카드 등에 표시할 대분류 라벨.
func category_display_name() -> String:
	return "패시브" if category == Category.PASSIVE else "액티브"

## 정수면 "15", 소수면 "12.5"처럼 불필요한 소수점을 생략해서 표시.
static func _format_number(value: float) -> String:
	if value == floor(value):
		return str(int(value))
	return "%.1f" % value
