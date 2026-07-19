class_name BaseAttackObject
extends Area2D
## 모든 "공격 오브젝트"(투사체, 근접 히트박스, 장판, 지뢰 등)의 최상위 부모.
## "Enemy와 겹치면 데미지(+선택적으로 상태이상)를 준다"는 가장 기본적인 계약만 여기서 처리하고,
## 이동/사거리, 지속시간/페이드, 포물선 낙하 같은 "형태별 차이"는 이 클래스를 상속하는
## 중간 베이스가 각자 담당합니다.
##
##   BaseAttackObject (Area2D) ── 데미지 전달 + 상태이상 훅의 공통 계약
##     ├─ BaseProjectile        : 발사형(이동 + 사거리). 예: 깃털 다트.
##     ├─ BaseOrbitBody         : 위성 공전형(플레이어 주위 회전 + 반복 타격). 예: 골판 두르기.
##     ├─ BaseAreaEffect        : 장판형(고정 또는 서서히 이동 + 지속시간 + 페이드). 예: 무리 사냥.
##     └─ BaseLobbedProjectile  : 곡사형(목표 지점까지 포물선으로 이동 후 착탄). 예: 알 폭탄.
##
## 새 공격 오브젝트를 추가할 때, 위 4개 중 하나와 형태가 비슷하면 그걸 상속하고,
## 완전히 새로운 형태(예: 레이저 빔)라면 이 클래스를 직접 상속해서 필요한 걸 새로 구현하세요.

@export var damage: float = 10.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	var enemy := body as Enemy
	if enemy != null:
		_on_hit_enemy(enemy)

## 하위 클래스 오버라이드용. 기본 동작: 데미지만 주고 끝(넉백/출혈 등 상태이상 없음).
## 상태이상이 있는 공격(철퇴의 넉백, 무리 사냥 진화의 출혈 등)은 이 함수를 오버라이드해서
## super._on_hit_enemy(enemy)로 데미지를 준 뒤 상태이상을 추가로 적용하세요.
func _on_hit_enemy(enemy: Enemy) -> void:
	enemy.take_damage(damage)

## 반경 radius 안의 모든 Enemy에게 amount 데미지. 폭발/장판형 AOE 로직에서 공용으로 사용.
## hit_callback을 주면 데미지 적용 후 각 대상에 대해 추가로 호출(상태이상 부여 등에 사용).
func _deal_aoe_damage(center: Vector2, radius: float, amount: float, hit_callback: Callable = Callable()) -> void:
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy := node as Enemy
		if enemy == null:
			continue
		if center.distance_to(enemy.global_position) <= radius:
			enemy.take_damage(amount)
			if hit_callback.is_valid():
				hit_callback.call(enemy)

## CollisionShape2D(CircleShape2D) 자식이 있으면 그 반경을 given_radius로 동기화합니다.
## sub-resource는 같은 씬을 쓰는 인스턴스끼리 공유되므로, 직접 고치지 않고 복제 후 대입해서
## 한 인스턴스의 반경 변경이 다른 인스턴스에 번지는 사고를 방지합니다.
## (장판형은 damage_for_level처럼 인스턴스마다 반경이 달라지는 경우가 많아 필요 — 골판/알처럼
## 반경이 고정이면 안 불러도 됨)
func _sync_collision_radius(given_radius: float) -> void:
	var shape_node := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null or not (shape_node.shape is CircleShape2D):
		return
	var circle := (shape_node.shape as CircleShape2D).duplicate() as CircleShape2D
	circle.radius = given_radius
	shape_node.shape = circle

## 가장 가까운 Enemy를 찾습니다. 없으면 null. 자율 추적형 오브젝트(추적하는 장판 등)에서 사용.
func _find_nearest_enemy() -> Enemy:
	var nearest: Enemy = null
	var nearest_dist := INF
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy := node as Enemy
		if enemy == null:
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest
