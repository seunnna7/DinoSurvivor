class_name SkillData
extends Resource
## 스킬 하나를 정의하는 데이터 리소스.
## 새 스킬을 추가할 때 이 스크립트를 건드릴 필요 없이,
## 이 스키마를 기반으로 data/skills/ 안에 새 .tres 파일만 만들면 됩니다.
## (Godot 에디터에서 우클릭 > New Resource > SkillData 로 생성 가능)

enum Stance { QUADRUPED, BIPED, BOTH }

const DAMAGE_PLACEHOLDER := "(데미지_숫자)"  ## flavor_text 안에 이 문자열을 적어두면 description()이 base_damage로 치환

@export var id: StringName
@export var display_name: String
@export var species_motif: String
@export_multiline var flavor_text: String  ## 플레이버 텍스트 보이스 공식 적용 (기획서 4.1.1). DAMAGE_PLACEHOLDER를 넣어두면 카드에 실제 데미지가 채워짐

@export_group("분류")
@export var tags: Array[StringName] = []  ## 자유 태그 (예: "melee", "summon", "projectile", "bomb"). 스킬 변주 체크와 향후 태그 기반 버프("소환수 강화" 등)에 공용으로 사용
@export var preferred_stance: Stance = Stance.BOTH

@export_group("수치")
@export var base_damage: float = 10.0
@export var cooldown: float = 1.0
@export var max_level: int = 5  ## 진화(만렙) 기준 (기획서 4.3)

@export_group("씬 참조")
@export var effect_scene: PackedScene  ## 투사체/이펙트 씬 (있는 경우)
@export var logic_scene: PackedScene   ## 이 스킬의 실제 동작을 구현한 로직 씬 (SkillInstanceBase 상속). 비어있으면 "더미"(UI에만 존재, 실제 동작 없음)

@export_group("표시")
@export var icon_color: Color = Color(0.8, 0.8, 0.8, 1.0)  ## 스킬 아이콘 자리표시용 색상 (실제 아이콘 이미지로 교체 전까지)

## 스킬 카드에 표시할 설명. flavor_text 그대로 쓰되, DAMAGE_PLACEHOLDER 자리에 실제 base_damage를 채워 넣습니다.
func description() -> String:
	return flavor_text.replace(DAMAGE_PLACEHOLDER, _format_number(base_damage))

## 정수면 "15", 소수면 "12.5"처럼 불필요한 소수점을 생략해서 표시.
static func _format_number(value: float) -> String:
	if value == floor(value):
		return str(int(value))
	return "%.1f" % value
