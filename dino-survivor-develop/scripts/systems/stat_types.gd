class_name StatTypes
extends RefCounted
## 기획서 6.4 / 엑셀 Stats 시트와 1:1 대응하는 스탯 정의.
## 새 스탯이 필요하면 여기에 추가하고, 엑셀 Stats 시트에도 같은 이름으로 행을 추가합니다.

enum Category { BASIC, DETAIL }

const CATEGORY_BY_STAT := {
	&"max_health": Category.BASIC,
	&"damage_mult": Category.BASIC,
	&"armor": Category.BASIC,
	&"move_speed": Category.DETAIL,
	&"cooldown_mult": Category.DETAIL,
	&"pickup_range": Category.DETAIL,
	&"crit_chance": Category.DETAIL,
}

const DEFAULT_VALUE := {
	&"max_health": 100.0,
	&"damage_mult": 1.0,
	&"armor": 0.0,
	&"move_speed": 150.0,
	&"cooldown_mult": 1.0,
	&"pickup_range": 40.0,
	&"crit_chance": 0.0,
}

static func is_basic(stat_id: StringName) -> bool:
	return CATEGORY_BY_STAT.get(stat_id, Category.DETAIL) == Category.BASIC
