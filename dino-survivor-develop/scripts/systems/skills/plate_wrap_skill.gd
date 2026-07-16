extends SkillInstanceBase
## 골판 두르기 (스테고사우루스 모티프, ORBIT 아키타입).
## 오각형 골판 여러 개가 플레이어 주변을 원형 궤도로 공전하며, 닿은 적에게 지속 데미지를 줍니다.
## 다른 스킬과 달리 쿨타임 트리거형(_perform)이 아니라 상시 지속형이라 _process()를 직접 오버라이드합니다.
## skill_data.cooldown 필드는 여기서는 "동일 대상 재타격 간격"으로 씁니다 (OrbitBlade.hit_interval).

const RADIUS := 60.0
const BLADE_COUNT := 3
const ROTATION_SPEED := 2.0  ## rad/sec
const BLADE_SCENE := preload("res://scenes/skills/OrbitBlade.tscn")

var _blades: Array[OrbitBlade] = []
var _orbit_angle: float = 0.0

func setup(data: SkillData, body: Node2D) -> void:
	super.setup(data, body)
	for i in BLADE_COUNT:
		var blade: OrbitBlade = BLADE_SCENE.instantiate()
		blade.damage = _leveled_damage()
		blade.hit_interval = skill_data.cooldown
		owner_body.add_child.call_deferred(blade)  # setup()이 트리 구성 중 호출될 수 있어 add_child를 지연
		_blades.append(blade)
	_show_range_indicator(RADIUS, Color(0.6, 0.55, 0.35, 0.35))

func _process(delta: float) -> void:
	_orbit_angle += ROTATION_SPEED * delta
	for i in _blades.size():
		var angle := _orbit_angle + i * (TAU / BLADE_COUNT)
		_blades[i].position = Vector2.RIGHT.rotated(angle) * RADIUS
