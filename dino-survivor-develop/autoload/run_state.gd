extends Node
## Autoload 싱글톤. 프로젝트 설정 > Autoload 에 등록해서 사용합니다.
## 현재 런(한 판) 동안의 상태를 전역으로 들고 있습니다.
## 씬이 바뀌어도(예: 레벨업 팝업 열고 닫기) 값이 유지되어야 하므로 Autoload로 둡니다.

signal leveled_up(new_level: int)                          ## 레벨업 UI가 이 신호를 받아 카드 팝업을 띄움
signal skill_acquired(data: SkillData)                      ## 스킬 신규 획득 (Lv.1) — HUD가 슬롯을 새로 추가
signal skill_leveled_up(data: SkillData, new_level: int)    ## 이미 보유한 스킬 레벨업 — HUD가 레벨 텍스트만 갱신
signal skill_removed(id: StringName)                        ## 진화로 베이스 스킬이 슬롯에서 사라질 때 — HUD가 슬롯 제거
signal evolution_ready(base_data: SkillData)                ## 스킬이 만렙+진화 옵션 보유 상태가 됐을 때 — EvolutionChoiceUI가 선택 팝업을 띄움
signal gold_changed(new_total: int)                         ## 골드 HUD가 이 신호를 받아 숫자를 갱신
signal experience_changed(current: int, needed: int)        ## 레벨/경험치 HUD가 이 신호를 받아 게이지 바를 갱신

const ACTIVE_SLOT_COUNT := 6  ## 액티브 스킬 슬롯 수 (기획서 3.2). 패시브 스킬은 슬롯을 차지하지 않음

## 15분 런에서 목표로 하는 레벨업 횟수. 6슬롯 × 5레벨 = 30회가 픽 예산의 구조적 상한이라
## (30회를 넘기면 모든 슬롯이 진화를 마쳐 더 이상 제시할 카드가 없어짐), 그보다 두 칸 낮게 잡아
## "어떻게 플레이해도 4개 이상은 확보되지만 6개를 전부 진화시키지는 못하는" 지점에 맞췄습니다.
const TARGET_LEVELUPS := 28

## 레벨업 곡선 계수. TARGET_LEVELUPS 도달에 필요한 누적 경험치가 15분치 수급량과 맞도록 역산한 값.
## 실제 수급률은 빌드/조작에 따라 달라지므로, 개발자 메뉴의 "15분 예상 레벨" 표시를 보고 조정하세요.
const XP_BASE := 20
const XP_GROWTH := 12

var current_species: SpeciesData
var current_stance: SkillData.Stance = SkillData.Stance.BIPED
var elapsed_time: float = 0.0

var level: int = 1
var experience: int = 0  ## 현재 레벨 내 누적 경험치. 다음 레벨 임계값을 넘으면 초기화됨
var total_experience: int = 0  ## 이번 런에서 획득한 경험치 총량. 레벨 곡선 튜닝용 계측값
var gold: int = 0

var owned_skills: Array[SkillData] = []  ## HUD 표시 순서 (획득한 순서)
var skill_levels: Dictionary = {}         ## StringName(스킬 id) -> int(레벨)

var is_game_over: bool = false  ## true인 동안 레벨업 카드 팝업 등 다른 일시정지 UI가 뜨지 않도록 막는 용도
var has_pending_evolution: bool = false  ## 진화 선택 UI가 떠 있는 동안 true — 레벨업 카드가 뒤이어 일시정지를 풀지 않도록 막는 가드

func reset_run() -> void:
	elapsed_time = 0.0
	level = 1
	experience = 0
	total_experience = 0
	gold = 0
	owned_skills.clear()
	skill_levels.clear()
	is_game_over = false
	has_pending_evolution = false

## 경험치 젬 등에서 호출. 임계값을 넘으면 레벨업하고 leveled_up을 emit합니다.
## 한 번에 여러 레벨을 넘을 수도 있어 while로 처리합니다.
func add_experience(amount: int) -> void:
	if is_game_over:
		return
	experience += amount
	total_experience += amount
	while experience >= xp_to_next_level():
		experience -= xp_to_next_level()
		level += 1
		leveled_up.emit(level)
	experience_changed.emit(experience, xp_to_next_level())

## 다음 레벨까지 필요한 경험치. 레벨당 필요량이 일정하게 증가하는(=누적은 2차 곡선) 형태.
func xp_to_next_level() -> int:
	return XP_BASE + (level - 1) * XP_GROWTH

## 지정한 레벨에 도달하기까지 필요한 경험치 총량. 곡선 튜닝 계측(개발자 메뉴)에서 사용.
static func total_xp_for_level(target_level: int) -> int:
	var levelups := target_level - 1
	if levelups <= 0:
		return 0
	return levelups * XP_BASE + XP_GROWTH * (levelups * (levelups - 1)) / 2

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

## 액티브 슬롯을 차지하고 있는 보유 스킬 수. 패시브 스킬은 세지 않습니다 (기획서 4.2.1).
func active_skill_count() -> int:
	var count := 0
	for data in owned_skills:
		if data.category == SkillData.Category.ACTIVE:
			count += 1
	return count

## 레벨업 카드가 "미보유 액티브 스킬"을 후보에 올려도 되는지 판단할 때 사용.
func has_free_active_slot() -> bool:
	return active_skill_count() < ACTIVE_SLOT_COUNT

## 진화 등으로 베이스 스킬이 슬롯에서 사라질 때 호출. skill_removed를 emit해 HUD 슬롯도 정리합니다.
func remove_skill(id: StringName) -> void:
	skill_levels.erase(id)
	for i in range(owned_skills.size()):
		if owned_skills[i].id == id:
			owned_skills.remove_at(i)
			break
	skill_removed.emit(id)

## 생존시간(elapsed_time) 등 초 단위 값을 "분:초" 형태(예: 03:45)로 표시할 때 공용으로 사용
static func format_time(total_seconds: float) -> String:
	var total := int(total_seconds)
	var minutes := total / 60
	var seconds := total % 60
	return "%02d:%02d" % [minutes, seconds]
