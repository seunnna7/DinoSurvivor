extends Node
## Autoload 싱글톤. 프로젝트 설정 > Autoload 에 등록해서 사용합니다.
## 현재 런(한 판) 동안의 상태를 전역으로 들고 있습니다.
## 씬이 바뀌어도(예: 레벨업 팝업 열고 닫기) 값이 유지되어야 하므로 Autoload로 둡니다.

signal leveled_up(new_level: int)                          ## 레벨업 UI가 이 신호를 받아 카드 팝업을 띄움
signal skill_acquired(data: SkillData)                      ## 스킬 신규 획득 (Lv.1) — HUD가 슬롯을 새로 추가
signal skill_leveled_up(data: SkillData, new_level: int)    ## 이미 보유한 스킬 레벨업 — HUD가 레벨 텍스트만 갱신
signal gold_changed(new_total: int)                         ## 골드 HUD가 이 신호를 받아 숫자를 갱신
signal experience_changed(current: int, needed: int)        ## 레벨/경험치 HUD가 이 신호를 받아 게이지 바를 갱신

var current_species: SpeciesData
var current_stance: SkillData.Stance = SkillData.Stance.BIPED
var elapsed_time: float = 0.0

var level: int = 1
var experience: int = 0  ## 현재 레벨 내 누적 경험치. 다음 레벨 임계값을 넘으면 초기화됨
var gold: int = 0

var owned_skills: Array[SkillData] = []  ## HUD 표시 순서 (획득한 순서)
var skill_levels: Dictionary = {}         ## StringName(스킬 id) -> int(레벨)

var is_game_over: bool = false  ## true인 동안 레벨업 카드 팝업 등 다른 일시정지 UI가 뜨지 않도록 막는 용도

func reset_run() -> void:
	elapsed_time = 0.0
	level = 1
	experience = 0
	gold = 0
	owned_skills.clear()
	skill_levels.clear()
	is_game_over = false

## 경험치 젬 등에서 호출. 임계값을 넘으면 레벨업하고 leveled_up을 emit합니다.
## 한 번에 여러 레벨을 넘을 수도 있어 while로 처리합니다.
func add_experience(amount: int) -> void:
	if is_game_over:
		return
	experience += amount
	while experience >= xp_to_next_level():
		experience -= xp_to_next_level()
		level += 1
		leveled_up.emit(level)
	experience_changed.emit(experience, xp_to_next_level())

## 다음 레벨까지 필요한 경험치. 간단한 선형 증가 (추후 밸런싱 시 조정 예정)
func xp_to_next_level() -> int:
	return 10 + (level - 1) * 5

## 골드 코인 등에서 호출. 이번 런에서 번 골드는 게임 오버 시 MetaProgress로 합산됩니다.
func add_gold(amount: int) -> void:
	if is_game_over:
		return
	gold += amount
	gold_changed.emit(gold)

func is_skill_owned(id: StringName) -> bool:
	return skill_levels.has(id)

func skill_level(id: StringName) -> int:
	return skill_levels.get(id, 0)

## 생존시간(elapsed_time) 등 초 단위 값을 "분:초" 형태(예: 03:45)로 표시할 때 공용으로 사용
static func format_time(total_seconds: float) -> String:
	var total := int(total_seconds)
	var minutes := total / 60
	var seconds := total % 60
	return "%02d:%02d" % [minutes, seconds]
