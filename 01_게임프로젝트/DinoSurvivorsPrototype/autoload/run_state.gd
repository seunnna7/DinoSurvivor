extends Node
## Autoload 싱글톤. 프로젝트 설정 > Autoload 에 등록해서 사용합니다.
## 현재 런(한 판) 동안의 상태를 전역으로 들고 있습니다.
## 씬이 바뀌어도(예: 레벨업 팝업 열고 닫기) 값이 유지되어야 하므로 Autoload로 둡니다.

var equipped_skills: Array[SkillData] = []
var current_species: SpeciesData
var current_stance: SkillData.Stance = SkillData.Stance.BIPED
var elapsed_time: float = 0.0
var experience: int = 0  ## G4(레벨업)에서 레벨/임계값 판정에 사용 예정
var gold: int = 0

func reset_run() -> void:
	equipped_skills.clear()
	elapsed_time = 0.0
	experience = 0
	gold = 0
