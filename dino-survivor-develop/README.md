# Dinosaur Survivors Prototype
ㅎㅇㅎㅇ
마일스톤 G0(환경 세팅) + G1(플레이어 이동)에 해당하는 최소 실행 프로젝트입니다.

## 여는 방법

1. **Godot Engine 4.3 이상**을 설치합니다. https://godotengine.org/download (무료, 설치파일 실행하면 끝 — 별도 인스톨러 없이 실행파일 하나로 동작하는 버전도 있습니다)
2. Godot을 실행하면 뜨는 "프로젝트 매니저" 창에서 **"가져오기(Import)"** 버튼 클릭
3. 이 폴더 안의 `project.godot` 파일을 선택
4. 프로젝트 목록에 추가되면 더블클릭해서 열기
5. 상단의 **재생 버튼(▶, 또는 F5)** 을 누르면 바로 실행됩니다

## 지금 확인할 수 있는 것

- 방향키로 캐릭터(초록색 사각형)가 8방향 이동, 카메라가 따라감
- **몹이 티어별로 등장**: 일반(빨강, 시간에 따라 쥐→고양이로 단계 승급) / 정예(주황, 30초부터 30초 간격) / 보스(진한 빨강, 180초에 1회)
- **물기 스킬이 실제로 작동**: 플레이어 근처 가장 가까운 몹을 주기적으로 공격 (쿨다운 0.8초)
- **몹 처치 시 드랍 테이블에 따라 아이템이 실제로 나옴**: 경험치 젬(하늘색, 100%), 골드(금색, 티어별로 확률 다름) — 플레이어가 닿으면 `RunState.experience`/`gold`에 누적 (콘솔 로그 없음, 나중에 UI로 표시 예정)

## 데이터로 조정 가능한 것 (코드 안 열어도 됨)

- `data/enemies/*.tres` — 몹 스탯, 등장 시점(`unlock_time`), 스폰 간격
- `data/loot_tables/*.tres` — 드랍 확률/개수
- `data/skills/bite.tres` — 물기 데미지/쿨다운/만렙

## 폴더 구조

콘텐츠(데이터)와 로직(코드)을 분리한 확장형 구조입니다. 자세한 운영 원칙은 `폴더_관리_가이드.md` 참고.

```
DinoSurvivorsPrototype/
├── project.godot
├── autoload/                # 전역 싱글톤
│   ├── run_state.gd            # 런 상태 (경험치, 골드, 경과시간, 장착 스킬)
│   ├── skill_database.gd       # data/skills/ 전체 로드 + 조회
│   └── wave_manager.gd         # data/enemies/ 기반 티어별 스폰 관리
├── data/                    # 콘텐츠 데이터 (.tres) — 코드 없이 여기만 늘리면 됨
│   ├── skills/                 # 스킬 하나당 파일 하나 (예: bite.tres)
│   ├── species/                # 종족 하나당 파일 하나 (예: trex.tres)
│   ├── enemies/                # 몹 "단계" 하나당 파일 하나 (티어+stage로 구분)
│   ├── loot_tables/             # 드랍 테이블 (몹 여러 개가 같은 테이블 공유 가능)
│   └── fusion_recipes/          # 합체진화 레시피 (아직 비어있음, G6에서 사용)
├── resource_types/          # 위 data/ 파일들의 "틀"(스키마) 정의 — 거의 안 바뀜
│   ├── skill_data.gd
│   ├── species_data.gd
│   ├── enemy_stage_data.gd
│   ├── loot_entry.gd / loot_table.gd
│   └── fusion_recipe.gd
├── scenes/
│   ├── main/Main.tscn           # 게임 시작 씬 (root, EnemyContainer 포함)
│   ├── entities/
│   │   ├── Player.tscn            # 플레이어 (SkillController 자식 포함)
│   │   ├── Enemy.tscn              # 몹 씬 하나로 모든 몹 종류를 커버 (데이터로 구분)
│   │   └── pickups/                # XPGem.tscn, GoldCoin.tscn
│   ├── skills/                  # 스킬별 로직 씬 (예: BiteSkill.tscn)
│   └── ui/                      # 레벨업/탈피 등 UI 씬 (추가 예정)
├── scripts/
│   ├── entities/ (player.gd, enemy.gd)
│   ├── systems/
│   │   ├── main.gd                    # WaveManager 가동
│   │   ├── skill_controller.gd        # 장착 스킬 관리
│   │   ├── skill_instance_base.gd     # 모든 스킬 로직의 베이스 클래스
│   │   ├── skills/bite_skill.gd       # 물기 실제 동작
│   │   └── pickups/ (xp_gem.gd, gold_coin.gd)
│   ├── ui/                      # (추가 예정)
│   └── debug/grid_background.gd   # 테스트용, 나중에 삭제 가능
├── assets/ (art/, audio/)
└── .gitignore
```

## 코드 살펴보기 (메인 개발자용)

- `scripts/player.gd` — `@export`로 선언한 `move_speed` 변수는 Godot 에디터에서 Player 노드를 선택하면 우측 Inspector 창에 숫자 입력칸으로 뜹니다. 코드를 안 열어도 서브 개발자가 직접 속도를 조정해볼 수 있어요.
- `scenes/Player.tscn` — 지금은 초록 사각형(`ColorRect`)이 임시 그래픽입니다. 나중에 실제 스프라이트로 교체하려면 이 노드를 `Sprite2D`나 `AnimatedSprite2D`로 바꾸면 됩니다.
- `Camera2D`가 Player의 자식 노드로 붙어있어서 자동으로 따라다닙니다. `position_smoothing_speed` 값을 올리면 카메라가 더 빠르게 따라붙습니다.

## 다음 단계 (마일스톤 G4)

1. 레벨업 임계값 판정 (`RunState.experience` 기준) 및 일시정지 + 3택 UI
2. 새 스킬을 `equip_skill()`로 장착하는 흐름을 UI에 연결
3. 다른 스킬(박치기, 골판 등)도 `SkillInstanceBase`를 상속하는 로직 씬으로 하나씩 추가

## Git 세팅 (아직 안 하셨다면)

```bash
git init
git add .
git commit -m "G0-G1: 프로젝트 세팅 + 플레이어 이동"
```

`.gitignore`에 Godot 캐시 파일들이 이미 제외 설정되어 있습니다.
