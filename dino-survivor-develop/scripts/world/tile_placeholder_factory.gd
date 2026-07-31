class_name TilePlaceholderFactory
extends RefCounted
## 실제 아트가 준비되기 전까지 쓰는 자리표시용 지형 타일셋 / 장식 텍스처를 코드로 생성합니다.
## 색만 다른 단색 사각형이라 알아보기 쉽고, 이미지 파일이 없어도 바로 동작합니다.
##
## 실제 아트로 교체하려면: data/world/ 밑에 진짜 TileSet 리소스(.tres)를 만들고
## chunk.gd의 _ready()에서 get_ground_tileset() 호출을 그 리소스를 load()하는 코드로 바꾸면 됩니다.
## 청크 배치 로직(chunk.gd, chunk_manager.gd)은 그대로 재사용됩니다.

const TILE_SIZE := WorldGenConstants.TILE_SIZE

## 서로 다른 색으로 구분되는 지형 타일. 배열 순서 = 타일 id(0부터). 필요하면 색을 더 추가해도 됨.
const GROUND_COLORS: Array[Color] = [
	Color("4a9e4a"), # 0: 잔디(placeholder)
	Color("3a762dff"), # 0: 잔디(placeholder)
	Color("285528ff"), # 0: 잔디(placeholder)
#	Color("9c6b3f"), # 1: 흙길(placeholder)
#	Color("d6c580"), # 2: 모래(placeholder)
#	Color("4677a8"), # 3: 물/바위(placeholder)
]

## 장식(작은 스프라이트)용 색 — 노랑/검정.
const DECORATION_COLORS: Array[Color] = [
	Color("f2dc28"), # 노란 장식(placeholder)
	Color("161616"), # 검은 장식(placeholder)
]
const DECORATION_SIZE := 10  # 타일(32px)보다 작게

static var _cached_tile_set: TileSet
static var _cached_decoration_textures: Array[Texture2D] = []

static func get_ground_tileset() -> TileSet:
	if _cached_tile_set == null:
		_cached_tile_set = _build_ground_tileset()
	return _cached_tile_set

static func get_decoration_textures() -> Array[Texture2D]:
	if _cached_decoration_textures.is_empty():
		_cached_decoration_textures = _build_decoration_textures()
	return _cached_decoration_textures

static func _build_ground_tileset() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)

	var atlas_image := Image.create_empty(TILE_SIZE * GROUND_COLORS.size(), TILE_SIZE, false, Image.FORMAT_RGBA8)
	for i in GROUND_COLORS.size():
		var rect := Rect2i(i * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE)
		var color: Color = GROUND_COLORS[i]
		atlas_image.fill_rect(rect, color)
		_draw_border(atlas_image, rect, color.darkened(0.3))  # 타일 경계를 눈으로 확인하기 쉽게

	var atlas_source := TileSetAtlasSource.new()
	atlas_source.texture = ImageTexture.create_from_image(atlas_image)
	atlas_source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for i in GROUND_COLORS.size():
		atlas_source.create_tile(Vector2i(i, 0))

	tile_set.add_source(atlas_source, 0)
	return tile_set

static func _build_decoration_textures() -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	for color in DECORATION_COLORS:
		var img := Image.create_empty(DECORATION_SIZE, DECORATION_SIZE, false, Image.FORMAT_RGBA8)
		img.fill(color)
		_draw_border(img, Rect2i(0, 0, DECORATION_SIZE, DECORATION_SIZE), color.inverted())
		textures.append(ImageTexture.create_from_image(img))
	return textures

static func _draw_border(image: Image, rect: Rect2i, color: Color) -> void:
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		image.set_pixel(x, rect.position.y, color)
		image.set_pixel(x, rect.position.y + rect.size.y - 1, color)
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		image.set_pixel(rect.position.x, y, color)
		image.set_pixel(rect.position.x + rect.size.x - 1, y, color)
