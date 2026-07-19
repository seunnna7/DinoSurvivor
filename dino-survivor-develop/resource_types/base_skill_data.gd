class_name BaseSkillData
extends SkillData
## 확장형 스킬 프레임워크의 데이터 앵커.
## 아이콘/이름/설명/최대레벨/태그/진화 등 모든 스킬의 공통 필드는 이미 부모(SkillData)가 들고 있습니다.
## 투사체형/장판형/위성형 등 "전용 로직 클래스를 갖춘" 신규 스킬의 데이터 리소스는
## SkillData를 직접 상속하지 않고 이 클래스를 상속해서 정의합니다 (예: MeleeSkillData, FeatherDartData).
## 스킬마다 달라지는 고유 수치(레벨별 사거리, 도탄 횟수 등)는 각 하위 클래스에 정의하세요.
##
## 레벨별 데미지 배율만은 모든 스킬이 공통으로 필요해서 여기(부모)에 둡니다 — 스킬마다
## "몇 레벨에 얼마나 세지는지" 곡선이 전부 달라야 하므로, 하나의 선형 공식 대신 레벨별 배율을
## 직접 데이터로 적어 넣는 방식입니다.

@export_group("레벨별 데미지 (인덱스 0 = Lv1)")
@export var level_damage: Array[float] = [1.0, 1.2, 1.4, 1.6, 1.8]  ## base_damage에 곱하는 배율. 기본값은 레벨당 +20%인 예전 공식과 동일.

## 스킬 레벨(1~5)에 맞는 최종 데미지(base_damage * 배율). 배열 범위를 벗어나면 마지막 값을 사용.
func damage_for_level(level: int) -> float:
	return base_damage * level_damage[clampi(level - 1, 0, level_damage.size() - 1)]
