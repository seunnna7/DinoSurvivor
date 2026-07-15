class_name LootEntry
extends Resource
## 드랍 테이블 안의 항목 하나. 항목마다 독립적으로 확률을 굴립니다.
## (예: 경험치는 항상 100%, 골드는 25%, 희귀 아이템은 2% — 서로 겹쳐서 동시에 나올 수 있음)

@export var item_scene: PackedScene
@export_range(0.0, 1.0, 0.01) var drop_chance: float = 1.0
@export var min_count: int = 1
@export var max_count: int = 1
