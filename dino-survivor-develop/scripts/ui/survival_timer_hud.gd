extends Label
## 화면 상단 중앙, 생존시간을 분:초로 실시간 표시.
## RunState.elapsed_time은 WaveManager._process에서만 누적되고, WaveManager는
## 기본 process_mode(PAUSABLE)라 게임 일시정지(레벨업 카드 등) 중엔 멈춘다 — 이 라벨도
## 같은 이유로 별도 신호 없이 매 프레임 값을 읽기만 해도 자동으로 함께 일시정지된다.

func _process(_delta: float) -> void:
	text = RunState.format_time(RunState.elapsed_time)
