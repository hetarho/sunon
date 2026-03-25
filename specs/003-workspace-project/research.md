# Research: 003-workspace-project

**Date**: 2026-03-25

## R1: Directory Selection on Desktop

- **Decision**: `file_picker` 패키지 (10.3.10) 사용
- **Rationale**: Flutter 데스크톱에서 OS 네이티브 디렉토리 선택 대화상자를 제공하는 가장 성숙한 패키지. `getDirectoryPath()` 메서드로 간단히 구현 가능.
- **Alternatives considered**:
  - `file_selector` (Google 공식) — 디렉토리 선택 미지원
  - 직접 platform channel 구현 — 불필요한 복잡도

## R2: Workspace Path Persistence

- **Decision**: `shared_preferences` 패키지 (2.5.4) 사용
- **Rationale**: 단일 문자열(workspace path) 저장에 최적. 모든 데스크톱 플랫폼 지원. Flutter 공식 추천 방식.
- **Alternatives considered**:
  - `hive` — 단일 값 저장에 과도함
  - 직접 파일 I/O — shared_preferences가 이미 추상화 제공

## R3: Multi-Window Support

- **Decision**: `desktop_multi_window` 패키지 (0.3.0) 사용
- **Rationale**: macOS/Windows/Linux 모두 지원. 각 창이 독립 Flutter 엔진 보유. 창 간 통신(WindowMethodChannel) 지원. mixin.dev 유지보수.
- **Alternatives considered**:
  - Flutter 공식 멀티윈도우 — 아직 Windows만 지원, macOS/Linux 미완성
  - 단일 윈도우 only — spec 요구사항(FR-007, FR-008) 미충족

## R4: Window Focus Detection

- **Decision**: `window_manager` 패키지 (0.5.1) 사용
- **Rationale**: `onWindowFocus` 이벤트로 포커스 획득 감지 가능. WidgetsBindingObserver는 데스크톱에서 포커스 감지 미지원.
- **Alternatives considered**:
  - `AppLifecycleListener` — 데스크톱에서 포커스 감지 제한적
  - `WidgetsBindingObserver` — 데스크톱 미지원
