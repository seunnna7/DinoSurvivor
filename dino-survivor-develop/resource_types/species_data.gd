class_name SpeciesData
extends Resource
## 공룡 종족(캐릭터) 하나를 정의하는 데이터 리소스.
## 새 종족을 추가할 때 코드 수정 없이 data/species/ 에 새 .tres 파일만 만들면 됩니다.

@export var id: StringName
@export var display_name: String
@export_multiline var passive_flavor_text: String  ## 사람이 읽는 설명 (UI 표시용)
@export var passive_modifiers: Array[StatModifierData] = []  ## 실제 계산에 쓰이는 구조화된 효과 (기획서 6.4)
@export var starting_skill: SkillData               ## 시작 스킬 (기획서 3.1). 공용 풀에도 그대로 포함됨 — 배타적 소유가 아니라 초기 장착일 뿐
@export var default_stance: SkillData.Stance = SkillData.Stance.BIPED  ## 기획서 5.2

@export_group("비주얼")
@export var scene: PackedScene  ## 이 종족의 Player 씬 (프로토타입은 티라노 1종만 존재)
