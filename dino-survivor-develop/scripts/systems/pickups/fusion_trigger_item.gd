extends Area2D
## 합체 트리거 아이템. 정예 몹 드랍 전용(기획서 4.5). 플레이어가 주우면
## RunState.fusion_trigger_count가 1 증가하고, 그 즉시 조건을 만족하는 합체 레시피가
## 있는지 확인합니다 (재료가 이미 전부 진화 완료된 상태였다면 여기서 바로 발동).

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	RunState.add_fusion_trigger(1)
	var skill_controller := body.get_node_or_null("SkillController") as SkillController
	if skill_controller != null:
		skill_controller.fuse_if_possible()
	queue_free()
