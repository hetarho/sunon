# Implementation Plan: Workspace & Project Management

**Branch**: `003-workspace-project` | **Date**: 2026-03-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/003-workspace-project/spec.md`

## Summary

Flutter 데스크톱 앱에서 workspace(디렉토리)와 project(하위 폴더) 개념을 구현한다. OS 네이티브 디렉토리 선택, 마지막 workspace 경로 복원, 멀티 윈도우, 포커스 시 목록 갱신을 포함한다. `file_picker`, `shared_preferences`, `window_manager`, `desktop_multi_window` 패키지를 활용한다.

## Technical Context

**Language/Version**: Dart ^3.11.1 (Flutter stable)
**Primary Dependencies**: file_picker 10.x, shared_preferences 2.x, window_manager 0.5.x, desktop_multi_window 0.3.x
**Storage**: shared_preferences (last workspace path 1개)
**Testing**: flutter_test
**Target Platform**: macOS, Windows, Linux (Flutter Desktop)
**Project Type**: desktop-app
**Performance Goals**: workspace 열기 <3초, 복원 <1초, 100+ 프로젝트 목록 스크롤 60fps
**Constraints**: offline-only, 로컬 파일 시스템 의존
**Scale/Scope**: 2 screens, 4 packages, ~10 files

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Speed Over Stability | PASS | 외부 패키지 적극 활용, 최소 구현 |
| II. Spec-Driven Development | PASS | spec.md → plan.md → tasks.md 순서 준수 |
| III. Minimal Viable Iteration | PASS | 프로젝트 상세 화면은 이후 기능으로 분리, 최근 기록도 범위 외 |
| IV. Platform Agnostic Authoring | PASS | 문서 전부 markdown |

**Post-Phase 1 Re-check**: PASS — 불필요한 추상화 없음, 패키지 4개는 각각 필수 기능 담당

## Project Structure

### Documentation (this feature)

```text
specs/003-workspace-project/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── ui-contracts.md
└── tasks.md
```

### Source Code (repository root)

```text
app/lib/
├── main.dart                          # Entry point, multi-window bootstrap
├── models/
│   ├── workspace.dart                 # Workspace model
│   └── project.dart                   # Project model
├── services/
│   ├── workspace_service.dart         # Directory scanning, filtering, sorting
│   └── persistence_service.dart       # shared_preferences wrapper
├── providers/
│   └── workspace_provider.dart        # ChangeNotifier state management
└── screens/
    ├── workspace_selection_screen.dart # Directory picker UI
    └── workspace_home_screen.dart     # Project list + active project UI

app/test/
├── models/
│   └── workspace_test.dart
└── services/
    └── workspace_service_test.dart
```

**Structure Decision**: Flutter 단일 앱 구조. `models/`, `services/`, `providers/`, `screens/` 4개 디렉토리로 관심사 분리. Constitution III(최소 반복) 원칙에 따라 별도 패키지나 레이어 없이 flat 구조 유지.

## Complexity Tracking

> No violations. Constitution gates all passed.
