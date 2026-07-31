extends Node
## Autoload 싱글톤. 플레이어 주변으로 청크(지형 타일 + 장식)를 동적으로 로드/언로드합니다.
##
## - 청크 크기/로드·언로드 반경: scripts/world/world_gen_constants.gd
## - 청크 하나의 내용물(타일 채우기/장식 배치): scripts/world/chunk.gd
## - 자리표시 타일/장식 텍스처 생성: scripts/world/tile_placeholder_factory.gd
##
## wave_manager.gd와 같은 패턴으로 Main.gd가 start(player, container)를 호출해서 가동합니다.
## 장애물/파괴 가능 오브젝트는 아직 다루지 않습니다(추후 청크 생성 로직에 추가 예정).

const CHUNK_SCENE := preload("res://scenes/world/Chunk.tscn")
const NO_CHUNK := Vector2i(999999, 999999)  # "아직 한 번도 갱신 안 됨"을 표시하는 값

var _player: Node2D = null
var _container: Node2D = null
var _running: bool = false
var _loaded: Dictionary = {}  # Vector2i(청크 좌표) -> Node2D(Chunk 인스턴스)
var _current_player_chunk: Vector2i = NO_CHUNK

func start(player: Node2D, container: Node2D) -> void:
	_player = player
	_container = container
	_running = true
	_current_player_chunk = NO_CHUNK
	_loaded.clear()  # 이전 런(재시작 등)의 청크 인스턴스는 이미 씬 트리에서 사라졌으므로 참조를 버림
	_update_chunks()

func stop() -> void:
	_running = false

func _process(_delta: float) -> void:
	if not _running or _player == null:
		return
	var chunk_coord := WorldGenConstants.world_to_chunk(_player.global_position)
	if chunk_coord != _current_player_chunk:
		_current_player_chunk = chunk_coord
		_update_chunks()

func _update_chunks() -> void:
	for dx in range(-WorldGenConstants.LOAD_RADIUS, WorldGenConstants.LOAD_RADIUS + 1):
		for dy in range(-WorldGenConstants.LOAD_RADIUS, WorldGenConstants.LOAD_RADIUS + 1):
			var coord := _current_player_chunk + Vector2i(dx, dy)
			if not _loaded.has(coord):
				_load_chunk(coord)

	for coord in _loaded.keys():
		var offset: Vector2i = coord - _current_player_chunk
		if maxi(absi(offset.x), absi(offset.y)) > WorldGenConstants.UNLOAD_RADIUS:
			_unload_chunk(coord)

func _load_chunk(coord: Vector2i) -> void:
	var chunk := CHUNK_SCENE.instantiate()
	_container.add_child(chunk)
	chunk.setup(coord)
	_loaded[coord] = chunk

func _unload_chunk(coord: Vector2i) -> void:
	var chunk: Node2D = _loaded.get(coord)
	if chunk == null:
		return
	_loaded.erase(coord)
	chunk.queue_free()
