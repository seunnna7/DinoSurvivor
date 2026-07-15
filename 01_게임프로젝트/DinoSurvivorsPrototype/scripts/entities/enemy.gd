extends CharacterBody2D
class_name Enemy
## 몹 로직 (마일스톤 G2 개편)
## 씬은 이 하나뿐이고, EnemyStageData(티어+단계 데이터)를 주입받아 종류를 결정합니다.
## 스탯을 코드에 하드코딩하지 않았기 때문에, 새 몹은 코드 수정 없이 데이터 파일만 추가하면 됩니다.

const CONTACT_DAMAGE_INTERVAL := 0.5
const CONTACT_RANGE := 20.0

var stage_data: EnemyStageData
var health: float

var _player: Node2D
var _contact_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	_player = get_tree().get_first_node_in_group("player")

## WaveManager가 스폰 직후 반드시 호출해줘야 합니다.
func setup(data: EnemyStageData) -> void:
	stage_data = data
	health = data.max_health
	scale *= data.visual_scale
	var visual := get_node_or_null("Visual")
	if visual != null:
		visual.color = data.visual_color

func _physics_process(delta: float) -> void:
	if _player == null or stage_data == null:
		return
	velocity = global_position.direction_to(_player.global_position) * stage_data.move_speed
	move_and_slide()

	_contact_timer -= delta
	if _contact_timer <= 0.0 and global_position.distance_to(_player.global_position) < CONTACT_RANGE:
		_contact_timer = CONTACT_DAMAGE_INTERVAL
		if _player.has_method("take_damage"):
			_player.take_damage(stage_data.contact_damage)

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		_die()

func _die() -> void:
	if stage_data != null and stage_data.loot_table != null:
		stage_data.loot_table.roll(get_parent(), global_position)
	queue_free()
