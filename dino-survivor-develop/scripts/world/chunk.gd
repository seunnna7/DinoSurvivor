extends Node2D
## 청크 하나(지형 타일 + 장식)의 절차적 생성을 담당합니다.
## ChunkManager가 인스턴스화 직후 setup(coord)를 호출해서 채웁니다.
##
## 역할 분담: "언제 로드/언로드할지"는 chunk_manager.gd가, "이 청크 안에 뭘 채울지"는
## 이 스크립트가 담당합니다. 타일 배치 확률/장식 밀도를 바꾸고 싶으면 이 파일만 고치면 됩니다.
## 장애물/파괴 가능 오브젝트는 아직 이 스크립트에서 다루지 않습니다(추후 추가 예정).

const DECORATION_COUNT_RANGE := Vector2i(2, 5)  # 청크당 장식 개수(최소, 최대)

@onready var _ground_layer: TileMapLayer = $GroundLayer
@onready var _decoration_container: Node2D = $DecorationContainer

func _ready() -> void:
	_ground_layer.tile_set = TilePlaceholderFactory.get_ground_tileset()

## ChunkManager가 add_child() 직후 호출합니다.
func setup(coord: Vector2i) -> void:
	position = Vector2(coord * WorldGenConstants.CHUNK_SIZE_PX)
	var rng := WorldGenConstants.rng_for_chunk(coord)
	_fill_ground(rng)
	_scatter_decorations(rng)

func _fill_ground(rng: RandomNumberGenerator) -> void:
	var tile_count := TilePlaceholderFactory.GROUND_COLORS.size()
	for x in WorldGenConstants.CHUNK_TILES:
		for y in WorldGenConstants.CHUNK_TILES:
			var tile_index := rng.randi_range(0, tile_count - 1)
			_ground_layer.set_cell(Vector2i(x, y), 0, Vector2i(tile_index, 0))

func _scatter_decorations(rng: RandomNumberGenerator) -> void:
	var textures := TilePlaceholderFactory.get_decoration_textures()
	var count := rng.randi_range(DECORATION_COUNT_RANGE.x, DECORATION_COUNT_RANGE.y)
	for i in count:
		var deco := Sprite2D.new()
		deco.texture = textures[rng.randi_range(0, textures.size() - 1)]
		deco.position = Vector2(
			rng.randf_range(0.0, WorldGenConstants.CHUNK_SIZE_PX),
			rng.randf_range(0.0, WorldGenConstants.CHUNK_SIZE_PX)
		)
		_decoration_container.add_child(deco)
