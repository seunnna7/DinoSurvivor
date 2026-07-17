extends Node
## Autoload 싱글톤. data/skills/ 안의 모든 SkillData를 자동으로 로드해
## 어디서든 조회할 수 있게 해줍니다. 새 스킬 .tres 파일을 추가해도
## 이 스크립트를 건드릴 필요가 없습니다 (폴더를 스캔하기 때문).

const SKILLS_PATH := "res://data/skills/"

var all_skills: Array[SkillData] = []

func _ready() -> void:
	_load_all_skills()

func _load_all_skills() -> void:
	var dir := DirAccess.open(SKILLS_PATH)
	if dir == null:
		push_warning("스킬 데이터 폴더를 찾을 수 없습니다: %s" % SKILLS_PATH)
		return
	for file_name in dir.get_files():
		if file_name.ends_with(".tres"):
			var skill: SkillData = load(SKILLS_PATH + file_name)
			all_skills.append(skill)

func get_skill(id: StringName) -> SkillData:
	for skill in all_skills:
		if skill.id == id:
			return skill
	return null

## 모든 스킬이 공용 풀에 포함됨 (시작 스킬도 예외 없음, 기획서 3.3)
func get_common_pool_skills() -> Array[SkillData]:
	return all_skills
