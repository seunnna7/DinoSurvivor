extends Node
## SkillData.tags의 내부 id(예: "summon")를 플레이어에게 보여줄 한글 라벨(예: "소환수")로 변환합니다.
## 새 태그를 추가하면 DISPLAY_NAMES에 한 줄만 추가하면 됩니다 (기획서 4.3.1).

const DISPLAY_NAMES: Dictionary = {
	&"melee": "근접",
	&"orbit": "회전",
	&"dash": "돌진",
	&"summon": "소환수",
	&"burst": "버스트",
	&"ranged_pierce": "관통",
	&"ranged_spread": "확산",
	&"suction": "흡입",
	&"utility": "유틸",
}

## 매핑에 없는 태그(추가 직후 라벨을 아직 안 붙인 경우 등)는 원본 id를 그대로 보여줌
func display_name(tag: StringName) -> String:
	return DISPLAY_NAMES.get(tag, String(tag))

## 스킬 카드 등에서 태그 여러 개를 한 줄로 이어붙여 보여줄 때 사용
func joined_display_names(tags: Array[StringName], separator: String = " · ") -> String:
	var names: PackedStringArray = []
	for tag in tags:
		names.append(display_name(tag))
	return separator.join(names)
