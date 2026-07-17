class_name FusionRecipe
extends Resource
## 합체 레시피: 재료 N개 + 결과물 1개.
##
## 기본은 재료 2개지만, ingredients를 배열로 설계해뒀기 때문에
## 예외적으로 3개 이상 요구하는 레시피도 스키마 변경 없이 추가할 수 있고,
## 나중에 볼X핏형 다단계 체인(이전 합체 결과물이 다시 재료가 되는 구조)으로
## 확장하고 싶어져도 이 스키마를 그대로 재사용할 수 있습니다. (기획서 4.6 참고)

@export var id: StringName
@export var ingredients: Array[SkillData] = []
@export var require_all_evolved: bool = true  ## 기획서 4.3: 재료가 전부 진화(만렙=Lv1인 진화형 상태)를 마쳐야 합체 (클라이맥스 지향)
@export var result: SkillData
