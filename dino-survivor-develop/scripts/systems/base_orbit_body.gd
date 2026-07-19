class_name BaseOrbitBody
extends Area2D
## 위성 공전형 스킬이 플레이어 주위로 띄우는 오브젝트 하나(예: 골판 두르기의 골판)의
## 공통 충돌/반복 타격 로직. BaseOrbitSkill이 이 클래스를 orbit_body_count개 스폰해서
## 위치(공전 각도)만 매 프레임 갱신하고, "닿은 적에게 hit_interval마다 반복 데미지"는
## 여기서 전담합니다.
##
## 새 위성형 스킬의 오브젝트는 이 클래스를 상속해서 시각 요소(씬의 자식 Polygon2D 등)만
## 다르게 구성하면 됩니다 — 충돌/타격 코드를 새로 작성할 필요가 없습니다.

var damage: float = 0.0
var hit_interval: float = 0.4

var _hit_timers: Dictionary = {}  ## Enemy -> float(다음 타격까지 남은 시간)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		_hit_timers[body] = 0.0  # 닿는 즉시 1회 타격

func _on_body_exited(body: Node2D) -> void:
	_hit_timers.erase(body)

func _physics_process(delta: float) -> void:
	for enemy in _hit_timers.keys():
		if not is_instance_valid(enemy):
			_hit_timers.erase(enemy)  # body_exited가 도착하기 전에 다른 공격으로 이미 freed된 경우
			continue
		_hit_timers[enemy] -= delta
		if _hit_timers[enemy] <= 0.0:
			enemy.take_damage(damage)
			_hit_timers[enemy] = hit_interval
