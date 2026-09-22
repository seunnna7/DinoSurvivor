class_name GroundTileSetLoader
extends RefCounted
## 실제 아트(assets/art/map_tile.png)로 만드는 지형 타일셋.
## 버티컬 슬라이스 범위에선 타일 1종만 사용 — 나중에 타일이 늘어나면 SOURCE_PATH를
## "타일 0번부터 가로로 32px 간격 배치된" 스프라이트시트로 바꾸고 TILE_COUNT만 늘리면 됨
## (TilePlaceholderFactory의 절차적 생성 방식과 동일한 배열 확장 원칙).
##
## 원본 아트(map_tile.png)가 421x421 등 32px 배수가 아닌 임시 크기라, 지금은 32x32로
## 강제 리샘플링해서 씀 — 디테일이 뭉개지는 임시 처리이며, 실제 32x32 규격 아트가 나오면
## 이 리샘플링 없이 바로 써도 되도록 코드는 그대로 둬도 됨(크기가 이미 맞으면 resize()가 사실상 무해).

const TILE_SIZE := WorldGenConstants.TILE_SIZE
const SOURCE_PATH := "res://assets/art/map_tile.png"
const TILE_COUNT := 1

static var _cached_tile_set: TileSet

static func get_ground_tileset() -> TileSet:
	if _cached_tile_set == null:
		_cached_tile_set = _build_tileset()
	return _cached_tile_set

static func _build_tileset() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)

	var source_texture := load(SOURCE_PATH) as Texture2D
	var image := source_texture.get_image()
	image.resize(TILE_SIZE * TILE_COUNT, TILE_SIZE, Image.INTERPOLATE_LANCZOS)

	var atlas_source := TileSetAtlasSource.new()
	atlas_source.texture = ImageTexture.create_from_image(image)
	atlas_source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for i in TILE_COUNT:
		atlas_source.create_tile(Vector2i(i, 0))

	tile_set.add_source(atlas_source, 0)
	return tile_set
