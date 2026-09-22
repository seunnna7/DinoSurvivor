extends Node
## Autoload 싱글톤. data/fusion_recipes/ 안의 모든 FusionRecipe를 자동으로 로드합니다.
## SkillDatabase와 동일한 패턴 — 새 레시피 .tres 파일을 추가해도 이 스크립트는 건드릴 필요 없음.

const RECIPES_PATH := "res://data/fusion_recipes/"

var all_recipes: Array[FusionRecipe] = []

func _ready() -> void:
	_load_all_recipes()

func _load_all_recipes() -> void:
	var dir := DirAccess.open(RECIPES_PATH)
	if dir == null:
		push_warning("합체 레시피 폴더를 찾을 수 없습니다: %s" % RECIPES_PATH)
		return
	for file_name in dir.get_files():
		if file_name.ends_with(".tres"):
			var recipe: FusionRecipe = load(RECIPES_PATH + file_name)
			all_recipes.append(recipe)
