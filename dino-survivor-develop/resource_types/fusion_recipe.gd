class_name FusionRecipe
extends Resource
## 합체진화 레시피: 재료 N개 + 결과물 1개.
##
## 지금은 페어형(재료 2개)만 쓰지만, ingredients를 배열로 설계해뒀기 때문에
## 나중에 볼X핏형 다단계 체인(재료 여러 개, 또는 이전 결과물이 다시 재료가 되는 구조)으로
## 확장하고 싶어져도 이 스키마를 그대로 재사용할 수 있습니다. (기획서 4.6 참고)

@export var id: StringName
@export var ingredients: Array[SkillData] = []
@export var require_all_max_level: bool = true  ## 기획서 4.3: 재료 전부 만렙이어야 합체 (클라이맥스 지향)
@export var result: SkillData
