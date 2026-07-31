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

@export var launch_tilt_degrees: float = 30.0  ## 발사 각도와 무관하게, 스프라이트 기본 자세에서 좌우 랜덤으로 주는 초기 기울기
@export var trajectory_lean_fraction: float = 0.4  ## 궤적 방향으로 "완전히" 정렬(1.0)할 필요 없이, 그쪽으로 어느 정도만 기울이는 비율

var _launch_tilt: float = 0.0
var _trajectory_turn: float = 0.0

## 발사 순간에는 궤적 방향과 무관하게, 스프라이트 기본 자세(윗부분이 화면 위)에서
## -launch_tilt_degrees~+launch_tilt_degrees 사이 랜덤 기울기만 준 채로 생성됩니다.
## 이후 _on_flight()에서 비행 진행률에 따라, 궤적 쪽으로 "어느 정도만"(trajectory_lean_fraction,
## 완전 정렬이 아니라 방향성만 느껴질 정도) 회전을 그 위에 추가로 얹습니다.
## 스프라이트의 기본 정면이 위쪽(-Y)이라, +X를 정면으로 가정하는 Vector2.angle() 결과에
## 90도(PI/2)를 더 얹어야 "위쪽 = 진행 방향"(완전 정렬 기준각)이 됩니다.
## 루트가 아니라 $Visual에 걸어야 합니다 — 루트는 화면 상승 오프셋 계산이 "로컬 -Y = 화면 위"를
## 전제하므로 무회전 상태를 유지해야 합니다(base_lobbed_projectile.gd 참고).
func launch(from_position: Vector2, to_position: Vector2) -> void:
	super.launch(from_position, to_position)
	_launch_tilt = deg_to_rad(randf_range(-launch_tilt_degrees, launch_tilt_degrees))
	_trajectory_turn = (from_position.direction_to(to_position).angle() + PI / 2.0) * trajectory_lean_fraction
	_visual.rotation = _launch_tilt

## 최초 랜덤 기울기(_launch_tilt)는 고정하고, 그 위에 궤적 방향으로의 부분 기울임(_trajectory_turn,
## 이미 trajectory_lean_fraction만큼만 반영된 값)을 진행률 t만큼 얹습니다 — t=0(발사 직후)에는
## 기울기만 있어 항상 윗부분이 화면 위 근처를 향하고, t=1(착탄)에는 기울기 + 부분 궤적 회전이 됩니다.
func _on_flight(t: float) -> void:
	_visual.rotation = _launch_tilt + _trajectory_turn * t

func _on_landed() -> void:
	if evolution == EggBombData.Evolution.EGG_CLUSTER:
		_scatter_mines()
		queue_free()
	else:
		super._on_landed()  # 기본형 / 형태 A(특란): 반경 aoe_radius 즉시 폭발(부모가 처리)

## 형태 B(알다발)는 착탄 지점 한 곳이 아니라 미니 알들이 흩어진 자리마다 터지므로,
## 실제 산개 위치(_mine_offset)마다 반경 mine_radius의 범위를 각각 미리 표시.
func _show_landing_indicators() -> void:
	if evolution != EggBombData.Evolution.EGG_CLUSTER:
		super._show_landing_indicators()
		return
	for i in mine_count:
		_add_landing_indicator(target + _mine_offset(i), mine_radius)

## 착탄 지점을 중심으로 mine_count개의 미니 알을 원형으로 균등 배치해서 흩뿌립니다.
func _scatter_mines() -> void:
	for i in mine_count:
		var mine: EggMine = MINE_SCENE.instantiate()
		mine.global_position = global_position + _mine_offset(i)
		mine.damage = damage
		mine.knockback_distance = knockback_distance
		mine.radius = mine_radius
		mine.lifetime = mine_lifetime
		get_parent().add_child(mine)

func _mine_offset(i: int) -> Vector2:
	var angle := TAU * float(i) / float(mine_count)
	return Vector2.RIGHT.rotated(angle) * mine_scatter_radius
