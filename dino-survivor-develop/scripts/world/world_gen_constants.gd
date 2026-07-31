class_name WorldGenConstants
extends RefCounted
## 청크 기반 무한 맵의 공용 상수 + 좌표 변환 헬퍼.
## 청크/로드 반경 수치를 바꾸고 싶으면 이 파일만 고치면 됩니다
## (ChunkManager/Chunk 스크립트는 건드릴 필요 없음).

const TILE_SIZE := 32                          # 타일 한 변(px)
const CHUNK_TILES := 16                         # 청크 한 변의 타일 개수
const CHUNK_SIZE_PX := TILE_SIZE * CHUNK_TILES  # 512px

const LOAD_RADIUS := 2    # 플레이어가 속한 청크 기준 이 반경(체비셰프 거리) 안은 항상 로드 상태 유지
const UNLOAD_RADIUS := 3  # 이 반경을 벗어나야 언로드. LOAD_RADIUS보다 한 칸 여유를 둬서
                           # 청크 경계에서 왔다갔다할 때 로드/언로드가 반복되는 것을 방지(히스테리시스).

const WORLD_SEED := 20260801  # 청크를 언로드했다가 다시 로드해도 같은 지형/장식이 나오게 하는 고정 시드

static func world_to_chunk(world_pos: Vector2) -> Vector2i:
	return Vector2i(floori(world_pos.x / CHUNK_SIZE_PX), floori(world_pos.y / CHUNK_SIZE_PX))

## 청크 좌표 기반 결정론적 RNG. 같은 좌표는 언제 다시 로드되어도 항상 같은 시퀀스를 냅니다.
static func rng_for_chunk(coord: Vector2i) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%d_%d_%d" % [coord.x, coord.y, WORLD_SEED])
	return rng
