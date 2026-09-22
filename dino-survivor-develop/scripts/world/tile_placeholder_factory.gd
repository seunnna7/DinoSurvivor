class_name TilePlaceholderFactory
extends RefCounted
## 실제 아트가 준비되기 전까지 쓰는 자리표시용 장식(작은 배경 오브젝트) 텍스처를 코드로 생성합니다.
## 색만 다른 단색 사각형이라 알아보기 쉽고, 이미지 파일이 없어도 바로 동작합니다.
## 지형(바닥) 타일셋은 실제 아트로 교체 완료 — ground_tileset_loader.gd 참고.

## 장식(작은 스프라이트)용 색 — 노랑/검정.
const DECORATION_COLORS: Array[Color] = [
	Color("f2dc28"), # 노란 장식(placeholder)
	Color("161616"), # 검은 장식(placeholder)
]
const DECORATION_SIZE := 10  # 타일(32px)보다 작게

static var _cached_decoration_textures: Array[Texture2D] = []

static func get_decoration_textures() -> Array[Texture2D]:
	if _cached_decoration_textures.is_empty():
		_cached_decoration_textures = _build_decoration_textures()
	return _cached_decoration_textures

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
