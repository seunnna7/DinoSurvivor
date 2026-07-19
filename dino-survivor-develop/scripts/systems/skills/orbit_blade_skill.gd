class_name OrbitBladeSkill
extends BaseOrbitSkill
## 골판 두르기 (스테고사우루스 모티프). 오브젝트 스폰/공전 갱신/반복 타격은 전부
## BaseOrbitSkill + BaseOrbitBody가 처리하므로, 여기서는 자신의 위성 오브젝트가
## 어떤 씬(OrbitBlade)인지만 알려줍니다.

const BLADE_SCENE := preload("res://scenes/skills/OrbitBlade.tscn")

func _create_orbit_body() -> BaseOrbitBody:
	var blade: OrbitBlade = BLADE_SCENE.instantiate()
	return blade

func _indicator_color() -> Color:
	return Color(0.6, 0.55, 0.35, 0.35)
