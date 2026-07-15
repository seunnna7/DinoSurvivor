extends Node2D
## Main 씬 루트 스크립트 (마일스톤 G2)
## 게임 시작 시 WaveManager를 가동시킵니다.

@onready var player: Node2D = $Player
@onready var enemy_container: Node2D = $EnemyContainer

func _ready() -> void:
	RunState.reset_run()
	WaveManager.start(player, enemy_container)
