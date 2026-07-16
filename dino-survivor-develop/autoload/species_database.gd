extends Node
## Autoload 싱글톤. data/species/ 안의 모든 SpeciesData를 자동으로 로드해
## 어디서든 조회할 수 있게 해줍니다. 새 종족 .tres 파일을 추가해도
## 이 스크립트를 건드릴 필요가 없습니다 (폴더를 스캔하기 때문). skill_database.gd와 동일한 방식.

const SPECIES_PATH := "res://data/species/"

var all_species: Array[SpeciesData] = []

func _ready() -> void:
	_load_all_species()

func _load_all_species() -> void:
	var dir := DirAccess.open(SPECIES_PATH)
	if dir == null:
		push_warning("종족 데이터 폴더를 찾을 수 없습니다: %s" % SPECIES_PATH)
		return
	for file_name in dir.get_files():
		if file_name.ends_with(".tres"):
			var species: SpeciesData = load(SPECIES_PATH + file_name)
			all_species.append(species)

func get_species(id: StringName) -> SpeciesData:
	for species in all_species:
		if species.id == id:
			return species
	return null
