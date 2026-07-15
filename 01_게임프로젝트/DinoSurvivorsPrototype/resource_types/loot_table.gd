class_name LootTable
extends Resource
## LootEntry 여러 개를 묶은 드랍 테이블. 몹이 죽을 때 roll()을 호출하면
## 각 항목을 독립 확률로 판정해서 실제 아이템을 스폰합니다.
##
## 향후 "진화 트리거" 같은 희귀 아이템도 낮은 drop_chance의 LootEntry로
## 추가하기만 하면 되는 구조입니다 (지금은 미포함).

@export var entries: Array[LootEntry] = []

func roll(parent: Node, spawn_position: Vector2) -> void:
	for entry in entries:
		if entry == null or entry.item_scene == null:
			continue
		if randf() > entry.drop_chance:
			continue
		var count := randi_range(entry.min_count, entry.max_count)
		for i in count:
			var item := entry.item_scene.instantiate()
			var jitter := Vector2(randf_range(-8.0, 8.0), randf_range(-8.0, 8.0))
			parent.add_child(item)
			item.global_position = spawn_position + jitter
