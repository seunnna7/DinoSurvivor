extends Node2D
## Main 씬 루트 스크립트 (마일스톤 G2)
## 게임 시작 시 WaveManager를 가동시킵니다.

@onready var player: Node2D = $Player
@onready var enemy_container: Node2D = $EnemyContainer

## _ready()는 자식(Player > SkillController 등)이 먼저 준비된 뒤 호출되기 때문에,
## 여기서 RunState.reset_run()을 부르면 SkillController가 등록한 시작 스킬이 초기화돼 버립니다.
## _enter_tree()는 반대로 부모가 먼저 호출되므로, 자식이 준비되기 전에 리셋을 끝낼 수 있습니다.
func _enter_tree() -> void:
	RunState.reset_run()
	if RunState.current_species != null:
		(get_node("Player") as Player).species = RunState.current_species

func _ready() -> void:
	WaveManager.start(player, enemy_container)
