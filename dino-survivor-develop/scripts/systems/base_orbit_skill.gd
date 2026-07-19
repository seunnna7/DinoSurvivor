class_name BaseOrbitSkill
extends BaseSkill
## 위성 공전형 스킬(골판 두르기 등)의 공통 로직. 물기/철퇴처럼 쿨타임마다 한 번씩 발동하는 게
## 아니라 상시 지속되는 오브젝트 여러 개를 플레이어 주위로 공전시키는 아키타입이라,
## BaseSkill의 쿨타임 트리거(_fire())를 쓰지 않고 _process()를 직접 오버라이드합니다.
## SkillData.cooldown은 여기서 사용하지 않습니다 — 재타격 간격은 OrbitSkillData.hit_interval이 담당.
##
## 오브젝트 개수(OrbitSkillData.level_orbit_body_count)가 레벨마다 다를 수 있어서, 매 프레임
## _sync_body_count()로 "현재 있어야 할 개수"와 실제 개수를 비교해 모자라면 스폰·남으면 정리합니다.
## 레벨업은 SkillController가 SkillInstanceBase.level만 갱신하고 별도 콜백을 주지 않기 때문에,
## setup() 한 번이 아니라 이렇게 매 프레임 동기화하는 방식으로 "레벨업 시 즉시 오브젝트 추가"를 보장합니다.
##
## 새 위성형 스킬을 추가하려면:
##   1. data/skills/에 OrbitSkillData .tres 추가 (반지름/속도/레벨별 개수/타격간격)
##   2. 이 클래스를 상속하는 스크립트를 작성하고 _create_orbit_body()만 구현
##      (자신의 오브젝트 씬을 인스턴스화해서 반환 — 트리에 추가하는 건 이 클래스가 처리)

var _bodies: Array[BaseOrbitBody] = []
var _orbit_angle: float = 0.0
var _indicator_shown: bool = false

## 상시 지속형이라 쿨타임 트리거(_fire) 대신 매 프레임 오브젝트 개수/공전 각도를 직접 갱신합니다.
func _process(delta: float) -> void:
	if skill_data == null:
		return
	var orbit_data := _orbit_data()
	_sync_body_count(orbit_data)
	if not _indicator_shown:
		_indicator_shown = true
		_show_range_indicator(orbit_data.orbit_radius, _indicator_color())
	if _bodies.is_empty():
		return
	_orbit_angle += orbit_data.rotation_speed * delta
	for i in _bodies.size():
		var angle := _orbit_angle + i * (TAU / _bodies.size())
		_bodies[i].position = Vector2.RIGHT.rotated(angle) * orbit_data.orbit_radius
		_bodies[i].damage = _leveled_damage()  # 레벨업으로 데미지가 바뀌면 기존 오브젝트에도 즉시 반영

## 현재 레벨에 맞는 오브젝트 개수와 실제 개수를 맞춥니다. 모자라면 새로 스폰, 남으면 정리.
func _sync_body_count(orbit_data: OrbitSkillData) -> void:
	var target_count := orbit_data.body_count_for_level(level)
	while _bodies.size() < target_count:
		var orbit_body := _create_orbit_body()
		orbit_body.damage = _leveled_damage()
		orbit_body.hit_interval = orbit_data.hit_interval
		owner_body.add_child.call_deferred(orbit_body)  # setup()이 트리 구성 중 호출될 수 있어 add_child를 지연
		_bodies.append(orbit_body)
	while _bodies.size() > target_count:
		var extra: BaseOrbitBody = _bodies.pop_back()
		extra.queue_free()

## 이 아키타입은 _process()를 직접 돌리므로 쿨타임 기반 _fire()는 사용하지 않습니다.
func _fire() -> void:
	pass

func _orbit_data() -> OrbitSkillData:
	return skill_data as OrbitSkillData

## 하위 클래스에서 반드시 override. 자신의 위성 오브젝트 씬을 인스턴스화해서 반환합니다
## (아직 트리에 추가되지 않은 상태로 반환 — add_child는 이 클래스가 처리).
func _create_orbit_body() -> BaseOrbitBody:
	push_warning("BaseOrbitSkill._create_orbit_body()이 구현되지 않았습니다: %s" % skill_data.id)
	return null
