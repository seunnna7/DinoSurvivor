class_name OrbitBlade
extends Area2D
## 골판 두르기의 골판 하나. plate_wrap_skill.gd가 스폰해서 매 프레임 위치를 갱신합니다.
## 겹친 적에게 hit_interval마다 반복 데미지를 줍니다 (enemy.gd의 접촉 데미지 판정과 같은 개념).

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
		_hit_timers[enemy] -= delta
		if _hit_timers[enemy] <= 0.0:
			enemy.take_damage(damage)
			_hit_timers[enemy] = hit_interval
