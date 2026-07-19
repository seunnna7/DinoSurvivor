class_name EggBombProjectile
extends BaseLobbedProjectile
## 알 폭탄 투사체. 기본형과 형태 A(특란)는 착탄 시 그 자리에서 폭발하는 부모(BaseLobbedProjectile)의
## 기본 동작을 그대로 씁니다 — 특란은 aoe_radius/cooldown이 크다는 "수치" 차이일 뿐이라 코드가 필요 없음.
## 형태 B(알다발)만 폭발 대신 미니 알(EggMine) 여러 개를 주변에 흩뿌리는 걸로 완전히 갈라집니다.

const MINE_SCENE := preload("res://scenes/skills/EggMine.tscn")

var evolution: EggBombData.Evolution = EggBombData.Evolution.NONE
var mine_count: int = 5
var mine_scatter_radius: float = 70.0
var mine_radius: float = 30.0
var mine_lifetime: float = 6.0

func _on_landed() -> void:
	if evolution == EggBombData.Evolution.EGG_CLUSTER:
		_scatter_mines()
		queue_free()
	else:
		super._on_landed()  # 기본형 / 형태 A(특란): 반경 aoe_radius 즉시 폭발(부모가 처리)

## 착탄 지점을 중심으로 mine_count개의 미니 알을 원형으로 균등 배치해서 흩뿌립니다.
func _scatter_mines() -> void:
	for i in mine_count:
		var angle := TAU * float(i) / float(mine_count)
		var offset := Vector2.RIGHT.rotated(angle) * mine_scatter_radius
		var mine: EggMine = MINE_SCENE.instantiate()
		mine.global_position = global_position + offset
		mine.damage = damage
		mine.radius = mine_radius
		mine.lifetime = mine_lifetime
		get_parent().add_child(mine)
