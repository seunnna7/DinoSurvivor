class_name EarthquakeSkill
extends BaseSkill
## 지진: 캐릭터가 바라보는 방향(facing_direction)으로, 캐릭터 바로 앞에서 시작해 그 방향으로
## 뻗어나가는 직사각형 범위에 균열(EarthquakeCrack)을 일으킵니다. 실제 전조/판정은
## BaseAreaEffect 기반의 EarthquakeCrack이 전담하므로, 여기서는 "어디에 얼마나 큰 균열을,
## 몇 개(진화 형태에 따라) 스폰할지"만 결정합니다.
##
##   - 기본형: 균열 1개.
##   - 진화 A(대격변): 같은 지점에 수직으로 교차하는 균열을 하나 더 동시에 스폰해 십자형으로 확장.
##   - 진화 B(여진): 1차 균열과 같은 자리에, 시차(aftershock_delay)를 두고 약화된 2차 균열을 추가 스폰.

const CRACK_SCENE := preload("res://scenes/skills/EarthquakeCrack.tscn")
const AFTERSHOCK_HIT_DELAY := 0.15  ## 여진은 이미 한 번 예고했으니, 짧게 다시 흔들리는 정도로만
const FADE_TAIL := 0.3  ## 판정 이후 균열이 남아 옅어지다 사라지기까지 추가로 주는 시간

func _fire() -> void:
	var data := skill_data as EarthquakeData
	var facing: Vector2 = owner_body.get("facing_direction")
	if facing == Vector2.ZERO:
		facing = Vector2.RIGHT
	facing = facing.normalized()
	# 캐릭터 발밑에서 시작해 바라보는 방향으로 rect_size.x만큼 뻗어나가도록, 사각형 중심을
	# 절반만큼 앞으로 밀어서 배치.
	var anchor := owner_body.global_position + facing * (data.rect_size.x * 0.5)
	var dmg := _leveled_damage()

	_spawn_crack(anchor, facing.angle(), data, dmg, data.cast_delay)
	if data.evolution == EarthquakeData.Evolution.CATACLYSM:
		_spawn_crack(anchor, facing.angle() + PI * 0.5, data, dmg, data.cast_delay)
	elif data.evolution == EarthquakeData.Evolution.AFTERSHOCK:
		await get_tree().create_timer(data.cast_delay + data.aftershock_delay).timeout
		_spawn_crack(anchor, facing.angle(), data, dmg * data.aftershock_damage_multiplier, AFTERSHOCK_HIT_DELAY)

func _spawn_crack(pos: Vector2, angle: float, data: EarthquakeData, dmg: float, hit_delay: float) -> void:
	# 주의: BaseAreaEffect는 hit_delay가 끝나는 즉시(또는 0이면 _ready()에서 바로) 스폰 지점을
	# 스캔해 데미지를 적용하므로, add_child()로 트리에 들어가기 전에 위치/수치를 전부 채워야 함.
	var crack: EarthquakeCrack = CRACK_SCENE.instantiate()
	crack.global_position = pos
	crack.rotation = angle
	crack.rect_size = data.rect_size
	crack.damage = dmg
	crack.knockback_distance = skill_data.knockback_distance
	crack.hit_delay = hit_delay
	crack.duration = hit_delay + FADE_TAIL
	owner_body.get_parent().add_child(crack)

## Lv3에서 쿨타임이 감소하도록, 데이터에 적힌 레벨별 배율을 cooldown에 곱함.
func _leveled_cooldown() -> float:
	var data := skill_data as EarthquakeData
	return data.cooldown * data.cooldown_multiplier_for_level(level)

func _indicator_color() -> Color:
	return Color(0.6, 0.4, 0.15, 0.35)
